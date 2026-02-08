#!/usr/bin/env fish

# workman.fish - Docker and Git worktree management script

set script_name (basename (status --current-filename))
set script_path (dirname (realpath (status --current-filename)))
set script_version "1.0.0"

function show_help
    echo "Usage: $script_name <command> [options]"
    echo ""
    echo "Commands:"
    echo "  init                       Create initial Dockerfile"
    echo "  build                      Build docker image"
    echo "  list                       List all git worktrees"
    echo "  add <branch>               Add a new git worktree for branch"
    echo "  enter <branch>             Enter a git worktree in shell"
    echo "  leave                      Enter project root in shell"
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

    echo "Creating Dockerfile in $project_root" >&2
    cp $script_path/Dockerfile $project_root/Dockerfile
end

function get_project_path
    git worktree list --porcelain -z | awk -v RS='\0' '/^worktree / {print substr($0, 10)}' | head
end

function build_image
    set -l project_root (get_project_path)
    set -l project_name (basename $project_root)
    # cp ~/.config/opencode/opencode.json .worktrees/opencode.json
    docker build \
        --build-arg "HTTP_PROXY=$(string replace 127.0.0.1 172.17.0.1 $http_proxy)" \
        --build-arg "HTTPS_PROXY=$(string replace 127.0.0.1 172.17.0.1 $https_proxy)" \
        -t git-worker-for-$project_name:latest $project_root
    # rm -f .worktrees/opencode.json
end

function run_worktree --argument-names branch
    if test -z "$branch"
        echo "Error: Branch name required" >&2
        echo "Usage: $script_name run <branch>" >&2
        return 1
    end

    set -l project_root (get_project_path)
    set -l project_name (basename $project_root)
    docker run \
        -e "http_proxy=$(string replace 127.0.0.1 172.17.0.1 $http_proxy)" \
        -e "https_proxy=$(string replace 127.0.0.1 172.17.0.1 $https_proxy)" \
        -e "all_proxy=$(string replace 127.0.0.1 172.17.0.1 $all_proxy)" \
        -e "no_proxy=$no_proxy,172.17.0.1" \
        -w "$project_root/.worktrees/$branch/$project_name" \
        -v "$HOME/.config/opencode:/home/ubuntu/.config/opencode:ro" \
        -v "$project_root:$project_root:ro" \
        -v "$project_root/.worktrees/$branch/$project_name:$project_root/.worktrees/$branch/$project_name" \
        -u (id -u):(id -g) \
        --add-host=host.docker.internal:host-gateway \
        --rm -it git-worker-for-$project_name:latest $argv[2..]
end

function list_worktrees
    set -l project_root (get_project_path)

    git worktree list | begin
        grep "$project_root/.worktrees/"; or begin
            echo "✗ No worktree yet" >&2
            return 1
        end
    end | sed 's/.*\[\(.*\)\]$/\1/g'
end

function leave_worktree
    set -l project_root (get_project_path)

    echo "Entering project root: $project_root" >&2

    fish -C "cd '$project_root'"
end

function enter_worktree --argument-names branch
    if test -z "$branch"
        echo "Error: Branch name required" >&2
        echo "Usage: $script_name add <branch>" >&2
        return 1
    end

    set -l project_root (get_project_path)
    set -l project_name (basename $project_root)
    set -l worktree_path "$project_root/.worktrees/$branch/$project_name"

    echo "Entering worktree for branch: $branch" >&2

    fish -C "cd '$worktree_path'"
end

function add_worktree --argument-names branch
    if test -z "$branch"
        echo "Error: Branch name required" >&2
        echo "Usage: $script_name add <branch>" >&2
        return 1
    end

    set -l project_root (get_project_path)
    set -l project_name (basename $project_root)
    set -l worktree_path "$project_root/.worktrees/$branch/$project_name"

    echo "Adding worktree for branch: $branch" >&2

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
    set -l project_name (basename $project_root)
    set -l worktree_path "$project_root/.worktrees/$branch/$project_name"

    echo "Removing worktree for branch: $branch" >&2

    # Remove worktree
    git worktree remove "$worktree_path"

    if test $status -ne 0
        echo "✗ Failed to remove worktree" >&2
        return 1
    end

    # Delete branch (silently)
    git branch -dq "$branch"

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
        case leave
            leave_worktree
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

