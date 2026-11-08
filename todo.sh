#!/bin/bash

FILE="${TODO_DB:-$HOME/.todo.txt}"

touch "$FILE"

help1() {
    echo "Использование:"
    echo "  $0 add <текст задачи>  — добавить новую задачу"
    echo "  $0 list               — показать список всех задач"
    echo "  $0 done <номер>        — отметить задачу как выполненную"
    echo "  $0 help               — показать эту справку"
}

add1() {
    shift
    if [ -z "$1" ]; then
        echo "Ошибка: не указана задача" >&2
        exit 1
    fi
    local task="$*"
    echo "[] $task" >> "$FILE"
    echo "Добавлено"
}

list1() {
    if [ ! -s "$FILE" ]; then
        echo "Список пуст"
        return
    fi
    local line_num=1
    while read -r line; do
        echo "${line_num}) ${line}"
        ((line_num++))
    done < "$FILE"
}

done1() {
    local task_num="$2"
    if [ -z "$task_num" ] || ! [[ "$task_num" =~ ^[0-9]+$ ]] || [ "$task_num" -le 0 ]; then
        echo "Ошибка: Укажите корректный номер задачи (целое положительное число)." >&2
        exit 1
    fi
    local total_lines
    total_lines=$(wc -l < "$FILE")
    if [ "$task_num" -gt "$total_lines" ]; then
        echo "Ошибка: Задача с номером $task_num не найдена." >&2
        exit 1
    fi
    local tmp_file
    tmp_file=$(mktemp)
    local current_line=1
    while IFS= read -r line; do
        if [ "$current_line" -eq "$task_num" ]; then
            echo "${line/\[\]/\[x\]}" >> "$tmp_file"
        else
            echo "$line" >> "$tmp_file"
        fi
        ((current_line++))
    done < "$FILE"
    mv "$tmp_file" "$FILE"
    echo "Отмечено"
}

case "$1" in
    add)
        add1 "$@"
        ;;
    list)
        list1
        ;;
    done)
        done1 "$@"
        ;;
    help|"")
        help1
        ;;
    *)
        echo "Ошибка: Неизвестная команда '$1'." >&2
        help1 >&2
        exit 1
        ;;
esac
