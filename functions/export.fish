function export
    if [ $argv ] 
        set var (echo $argv | cut -f1 -d=)
        set val (echo $argv | cut -f2 -d=)
        set -g -x $var $val
    else
        echo 'usage: export var=value'
    end
end

