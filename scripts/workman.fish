#!/usr/bin/env fish

# workman.fish - Docker and Git worktree management script

set script_name (basename (status --current-filename))
set script_path (dirname (realpath (status --current-filename)))
set script_version "1.0.0"
set dry_run false

function execute
    if $dry_run
        echo $argv
    else
        $argv
    end
end

function show_help
    echo "Usage: $script_name <command> [options]"
    echo ""
    echo "Commands:"
    echo "  init                       Create initial Dockerfile"
    echo "  build                      Build docker image"
    echo "  list                       List all git worktrees"
    echo "  add <branch>               Add a new git worktree for branch"
    echo "  enter <branch>             Enter a git worktree in shell"
    echo "  path-of <branch>           Print path of a git worktree"
    echo "  run <branch>               Run a git worktree in docker"
    echo "  remove <branch>            Remove a git worktree for branch"
    echo "  help                       Show this help message"
    echo "  version                    Show version"
    echo ""
    echo "Examples:"
    echo "  $script_name add feature/new-feature"
    echo "  $script_name run feature/new-feature"
    echo "  $script_name remove feature/new-feature"
end

function init_image
    set -l project_root (git rev-parse --show-toplevel)
    if test -z "$project_root"
        echo "✗ Not a git repository, please `git init` first" >&2
        return 1
    end

    echo "Creating Dockerfile in $project_root" >&2
    execute cp $script_path/Dockerfile $project_root/Dockerfile

    echo "Adding .worktrees to .gitignore" >&2
    execute mkdir -p $project_root/.worktrees/
    grep -q '^/.worktrees/$' $project_root/.gitignore 2> /dev/null; or execute fish -c "echo /.worktrees/ >> $project_root/.gitignore"
end

function get_project_path
    git worktree list --porcelain -z | awk -v RS='\0' '/^worktree / {print substr($0, 10)}' | head -1
end

function build_image
    set -l project_root (get_project_path)
    if test -z "$project_root"
        echo "✗ Not a git repository, please `git init` first" >&2
        return 1
    end
    set -l project_name (basename $project_root)

    if test -z "$project_name"; or not test -f Dockerfile
        echo "✗ Dockerfile not found, please `$script_name build` first" >&2
        return 1
    end

    # cp ~/.config/opencode/opencode.json .worktrees/opencode.json
    execute docker build \
        --build-arg "HTTP_PROXY=$(string replace 127.0.0.1 172.17.0.1 $http_proxy)" \
        --build-arg "HTTPS_PROXY=$(string replace 127.0.0.1 172.17.0.1 $https_proxy)" \
        -t "git-worker-for-$project_name:latest" $project_root
    # rm -f .worktrees/opencode.json
end

function run_worktree --argument-names branch
    if test -z "$branch"
        echo "Error: Branch name required" >&2
        echo "Usage: $script_name run <branch>" >&2
        return 1
    end

    set -l project_root (get_project_path)
    if test -z "$project_root"
        echo "✗ Not a git repository, please `git init` first" >&2
        return 1
    end
    set -l project_name (basename $project_root)

    set -l worktree_path (get_worktree_path $branch)
    if test $status -ne 0
        echo "✗ Branch or worktree not found" >&2
        return 1
    end

    if test "$(docker images --format json | grep "git-worker-for-$project_name" | jq .Repository -r)" != "git-worker-for-$project_name"
        echo "✗ Image not found, please `$script_name build` first" >&2
        return 1
    end

    execute docker run \
        -e "http_proxy=$(string replace 127.0.0.1 172.17.0.1 $http_proxy)" \
        -e "https_proxy=$(string replace 127.0.0.1 172.17.0.1 $https_proxy)" \
        -e "all_proxy=$(string replace 127.0.0.1 172.17.0.1 $all_proxy)" \
        -e "no_proxy=$no_proxy,172.17.0.1" \
        -w "$worktree_path" \
        -v "$HOME/.config/opencode:/home/ubuntu/.config/opencode:ro" \
        -v "$project_root:$project_root:ro" \
        -v "$worktree_path:$worktree_path" \
        -u (id -u):(id -g) \
        --add-host=host.docker.internal:host-gateway \
        --rm -it git-worker-for-$project_name:latest $argv[2..]
end

function list_worktrees
    git worktree list --porcelain -z | awk -v RS='\0' '/^branch refs\/heads\// {print substr($0, 19)}'
end

function get_worktree_path --argument-names branch
    git check-ref-format --branch "$branch" >/dev/null; or return 1
    git worktree list --porcelain | grep  "^branch refs/heads/$branch" >/dev/null ; or return 1
    git worktree list --porcelain | grep -B2 "^branch refs/heads/$branch" | head -1 | cut -d' ' -f 2
end

function path_of_worktree --argument-names branch
    if test -z "$branch"
        echo "Error: Branch name required" >&2
        echo "Usage: $script_name add <branch>" >&2
        return 1
    end

    get_worktree_path $branch
    if test $status -ne 0
        echo "✗ Branch or worktree not found" >&2
        return 1
    end
end

function enter_worktree --argument-names branch
    if test -z "$branch"
        echo "Error: Branch name required" >&2
        echo "Usage: $script_name add <branch>" >&2
        return 1
    end

    set -l worktree_path (get_worktree_path $branch)
    if test $status -ne 0
        echo "✗ Branch or worktree not found" >&2
        return 1
    end

    echo "Entering worktree for branch: $branch [$worktree_path]" >&2

    fish -C "cd '$worktree_path'"
end

function add_worktree --argument-names branch
    if test -z "$branch"
        echo "Error: Branch name required" >&2
        echo "Usage: $script_name add <branch>" >&2
        return 1
    end

    set -l project_root (get_project_path)
    if test -z "$project_root"
        echo "✗ Not a git repository, please `git init` first" >&2
        return 1
    end
    set -l project_name (basename $project_root)

    set -l worktree_path "$project_root/.worktrees/$branch/$project_name"

    echo "Adding worktree for branch: $branch [$worktree_path]" >&2

    # Create new worktree
    git worktree add -b "$branch" "$worktree_path"

    if test $status -eq 0
        echo "✓ Worktree created: $worktree_path" >&2
    else
        echo "✗ Failed to create worktree" >&2
        return 1
    end
end

function remove_worktree --argument-names branch
    if test -z "$branch"
        echo "Error: Branch name required" >&2
        echo "Usage: $script_name remove <branch>" >&2
        return 1
    end

    set -l project_root (get_project_path)
    if test -z "$project_root"
        echo "✗ Not a git repository, please `git init` first" >&2
        return 1
    end
    set -l project_name (basename $project_root)
    set -l worktree_path "$project_root/.worktrees/$branch/$project_name"

    echo "Removing worktree for branch: $branch" >&2

    # Remove worktree
    execute git worktree remove "$worktree_path"

    if test $status -ne 0
        echo "✗ Failed to remove worktree" >&2
        return 1
    end

    # Delete branch (silently)
    execute git branch -dq "$branch"

    if test $status -ne 0
        echo "✗ Failed to delete branch" >&2
        return 1
    end

    echo "✓ Worktree removed: $worktree_path" >&2
end

function main
    if test (count $argv) -eq 0
        show_help
        return 1
    end

    set -l command $argv[1]
    set -l args $argv[2..-1]

    switch $command
        case init
            init_image
        case build
            build_image
        case list
            list_worktrees
        case run
            run_worktree $args
        case add
            add_worktree $args[1]
        case enter
            enter_worktree $args[1]
        case path-of
            path_of_worktree $args[1]
        case remove
            remove_worktree $args[1]
        case help h --help -h
            show_help
        case version v --version -v
            echo "$script_name version $script_version"
        case '*'
            echo "Error: Unknown command '$command'" >&2
            show_help
            return 1
    end
end

# Run the main function with all arguments
main $argv

