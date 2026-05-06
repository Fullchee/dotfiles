# Files
alias o.="o ."

alias create-blank-jpg="ffmpeg -f lavfi -i color=c=black:s=1280x720 -t 1 blank.jpg"

alias resume="cd ~/projects/portfolio/public/assets"

compressmp4() {
	if [ -z "$1" ] ; then
		echo 'Usage: compressmp4 "file_path"'
		echo "Just use handbrake"
		return
	fi
	ffmpeg -i "$1" -acodec mp2 "compressed-$1"
}

compressmp4folder() {
	for file in "$PWD"/*; do
		ffmpeg -i "$file" -acodec mp2 "${file/.mp4/s.mp4}"
	done
}

compresspdf() {
	if [ -z "$1" ] ; then
	        echo 'Usage: compresspdf <pdf filename>'
        	return
   	fi
    /usr/local/bin/gs -sDEVICE=pdfwrite -dNOPAUSE -dQUIET -dBATCH -dPDFSETTINGS=/${3:-"screen"} -dCompatibilityLevel=1.4 -sOutputFile="$2" "$1"
}

compressresume() {
	rm -f ~/projects/portfolio/public/assets/Fullchee-Resume.pdf;
	compresspdf ~/Desktop/Fullchee-Resume.pdf ~/projects/portfolio/public/assets/Fullchee-Resume.pdf;
}

compress-video() {
    local input_file="$1"

    if [[ ! -f "$input_file" ]]; then
        echo "Error: File '$input_file' not found."
        return 1
    fi

    local temp_file="${input_file%.*}_temp.mp4"

    echo "Processing '$input_file'..."

    if ffmpeg -y -i "$input_file" \
        -vcodec libx264 \
        -crf 23 \
        -preset medium \
        -pix_fmt yuv420p \
        -acodec aac \
        -b:a 128k \
        -movflags +faststart \
        "$temp_file" < /dev/null; then

        mv -f "$temp_file" "$input_file"
        echo "Done! Original file replaced with compressed version."

    else
        echo "Error: Compression failed. Original file preserved."
        [[ -f "$temp_file" ]] && rm "$temp_file"
        return 1
    fi
}

concatmp3() {
	if [ -z "$3" ] ; then
		echo 'Usage: concatmp3 file1.mp3 file2.mp3 output.mp3'
		return
	fi
	ffmpeg -i "concat:$1|$2" -acodec copy "$3"
}

dropshadow() {
	if [ -z "$1" ] ; then
        echo 'Usage: dropshadow filename.png'
        return
    fi

    filename=$(basename -- "$1")
    basename="${filename%.*}"
    suffix=".png"
    convert "$1" \( +clone -background black -shadow 50x10+5+5 \) +swap -background none -layers merge +repage "$basename$suffix"
}

fastkoko() {
	set-terminal-tab-title "FastKoko: TTS 🔤 -> 💬"
	docker run --name FastKoko -p 8880:8880 ghcr.io/remsky/kokoro-fastapi-cpu:latest
	set-terminal-tab-title ""
}

flatten-pdf() {
	if [ -z "$1" ] ; then
		echo 'Usage: flatten-pdf existing.pdf flattened.pdf'
		return
   	fi
	convert -density 150 $1 $2
}

mp3slice() {
    if [ -z "$1" ] ; then
        echo 'Usage: mp3slice input.mp3 HH:MM:SS.mmm HH:MM:SS:mmm output.mp3'
        return
    fi
    ffmpeg -i "$1" -ss "$2" -to "$3" -c copy "$4"
}

mp3tomp4() {
    if [ -z "$1" ] ; then
        echo 'Usage: mp3tomp4 mp3File'
        return
    fi
	ffmpeg -loop 1 -i blank.jpg -i "$1" -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest output.mp4
}

mp3toyt() {
    if [ -z "$1" ]; then
        echo "Usage: mp3toyt <filename.mp3>"
        return 1
    fi

    local input="$1"
    local output="${input%.*}.mp4"

    ffmpeg -f lavfi -i color=c=black:s=1920x1080:r=5 \
           -i "$input" \
           -c:v libx264 -tune stillimage -pix_fmt yuv420p \
           -c:a copy -shortest "$output"

    echo "Conversion complete: $output"
}

shrinkimage() {
	if [ -z "$1" ] ; then
		echo 'Usage: shrinkimage src dest size'
		return
	fi
	convert "$1" -resize x"$3" "$2"
}

slice-av() {
	if [ -z "$3" ] ; then
        echo 'Usage: slice-av input.mp4 75 400'
		echo 'Usage: slice-av input.mp3 00:45:45 00:45:59'
        return
    fi
	local extension="${1##*.}"
	ffmpeg -ss "$2" -i "$1" -t "$3" -vcodec copy -acodec copy "output.$extension"
}

ssh-update-pihole-config() {
	cd "$HOME/projects/pihole-dotfiles"
	just ssh-update-config
	cd -
}
