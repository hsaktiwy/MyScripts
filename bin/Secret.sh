#!/bin/bash

show_help() {
    echo "Usage: $0 [-e | -d] [-s script | -p password] [-o] input [output]"
    echo
    echo "  -e               Encode the input"
    echo "  -d               Decode the input"
    echo "  -s script        External executable to use for encoding/decoding"
    echo "  -p password      Password for default encoding/decoding algorithm"
    echo "  -o               Overwrite input file with output (confirmation will be prompted)"
    echo "  input            Input file or string"
    echo "  output           Output file (optional, will display to stdout if omitted)"
}

default_encode() {
    local input="$1"
    local password="$2"
    echo -n "$input" | openssl aes-256-cbc -a -salt -pass pass:"$password"
}

default_decode() {
    local input="$1"
    local password="$2"
    echo -n "$input" | openssl aes-256-cbc -d -a -pass pass:"$password"
}

overwrite_input_file() {
    local input="$1"
    local output="$2"
    read -p "Are you sure you want to overwrite the content of '$input' with the decoded data? (y/n): " answer
    case ${answer:0:1} in
        y|Y )
            echo "Overwriting '$input' with decoded data..."
            echo "$output" > "$input"
            ;;
        * )
            echo "Operation aborted."
            exit 0
            ;;
    esac
}

while getopts "edp:soh" opt; do
    case ${opt} in
        e ) encode=true ;;
        d ) decode=true ;;
        p ) password="$OPTARG" ;;
        s ) script="$OPTARG" ;;
        o ) overwrite=true ;;
        h ) show_help; exit 0 ;;
        \? ) show_help; exit 1 ;;
    esac
done
shift $((OPTIND -1))

if [[ -z "$encode" && -z "$decode" ]]; then
    echo "Error: You must specify either -e (encode) or -d (decode)"
    show_help
    exit 1
fi

if [[ -n "$encode" && -n "$decode" ]]; then
    echo "Error: You cannot specify both -e (encode) and -d (decode)"
    show_help
    exit 1
fi

input="$1"
output="$2"

if [[ -f "$input" ]]; then
    input_data=$(cat "$input")
else
    input_data="$input"
fi

if [[ -n "$script" ]]; then
    if [[ ! -x "$script" ]]; then
        echo "Error: Script $script is not executable or does not exist."
        exit 1
    fi

    if [[ -n "$encode" ]]; then
        result=$("$script" "$input_data")
    else
        result=$("$script" "$input_data")
    fi
else
    if [[ -z "$password" ]]; then
        echo "Error: Password is required for default encoding/decoding algorithm."
        show_help
        exit 1
    fi

    if [[ -n "$encode" ]]; then
        result=$(default_encode "$input_data" "$password")
    else
        result=$(default_decode "$input_data" "$password")
    fi
fi

if [[ -n "$output" ]]; then
    echo "$result" > "$output"
else
    echo "$result"
fi

if [[ -n "$overwrite" ]]; then
    overwrite_input_file "$input" "$result"
fi

