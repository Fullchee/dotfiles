# Files
alias o.="o ."


fastkoko() {
	set-terminal-tab-title "FastKoko: TTS 🔤 -> 💬"
	docker run -p 8880:8880 ghcr.io/remsky/kokoro-fastapi-cpu:latest
	set-terminal-tab-title ""
}

slice-av() {
	if [ -z "$3" ] ; then
        echo 'Usage: slice-av input.mp4 75 400'
		echo 'Usage: slice-av input.mp3 00:45:45 00:45:59'
        return
    fi
	# extension="${$1##*.}"
	ffmpeg -ss "$2" -i "$1" -t "$3" -vcodec copy -acodec copy "output.$extension"
}

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

# ~/youtube-dl --extract-audio --audio-format mp3 "$url"
youtube-worst-audio() {
	if [ -z "$1" ] ; then
		echo 'Usage: youtube-worst-audio url1 url2 url3 ...'
		return
   	fi
	for url in "$@"
	do
		~/yt-dlp --extract-audio --audio-format mp3 --audio-quality worst -o "%(title)s.%(ext)s" --parse-metadata "title:%(title)s.replace(r' \[[a-zA-Z0-9_-]{11}\]$', '')" "$url"
	done
}

youtube-best-audio() {
	if [ -z "$1" ] ; then
		echo 'Usage: youtube-best-audio url1 url2 url3 ...'
		return
   	fi
	for url in "$@"
	do
		~/yt-dlp --extract-audio -f bestaudio -o "%(title)s.%(ext)s" "$url"
	done
}
alias y3-best=youtube-best-audio

# downloads a webm video
#yt-dlp "$url"

youtube-worst-video() {
	for url in "$@"
	do
		yt-dlp -f "b[filesize_approx<50M]" --no-playlist $url || \
		yt-dlp -f "b[height<=400]" --no-playlist $url || \
		yt-dlp -f "b" --no-playlist $url
	done
}

alias y3=youtube-worst-audio
alias y4=youtube-worst-video

# Convert MP3 to YouTube-ready MP4 with a black background
# Usage: mp3toyt input.mp3
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

compress-video() {
    local input_file="$1"

    # Check if file exists
    if [[ ! -f "$input_file" ]]; then
        echo "Error: File '$input_file' not found."
        return 1
    fi

    # Create a temporary output name
    # We cannot write directly to the input file while reading from it
    local temp_file="${input_file%.*}_temp.mp4"

    echo "Processing '$input_file'..."

    # Run FFmpeg
    # We use an 'if' statement to ensure the command succeeds before deleting anything
    if ffmpeg -y -i "$input_file" \
        -vcodec libx264 \
        -crf 23 \
        -preset medium \
        -pix_fmt yuv420p \
        -acodec aac \
        -b:a 128k \
        -movflags +faststart \
        "$temp_file" < /dev/null; then

        # If FFmpeg succeeds:
        # Move the temp file to the input filename (overwriting the original)
        mv -f "$temp_file" "$input_file"
        echo "Done! Original file replaced with compressed version."

    else
        # If FFmpeg fails:
        echo "Error: Compression failed. Original file preserved."
        # Clean up the partial temp file if it exists
        [[ -f "$temp_file" ]] && rm "$temp_file"
        return 1
    fi
}


mp3tomp4() {
    if [ -z "$1" ] ; then
        echo 'Usage: mp3tomp4 mp3File'
        return
    fi
	ffmpeg -loop 1 -i blank.jpg -i "$1" -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest output.mp4
}

alias create-blank-jpg="ffmpeg -f lavfi -i color=c=black:s=1280x720 -t 1 blank.jpg"

mp3slice() {
    if [ -z "$1" ] ; then
        echo 'Usage: mp3slice input.mp3 HH:MM:SS.mmm HH:MM:SS:mmm output.mp3'
        return
    fi
    ffmpeg -i "$1" -ss "$2" -to "$3" -c copy "$4"
}

concatmp3() {
	if [ -z "$3" ] ; then
		echo 'Usage: concatmp3 file1.mp3 file2.mp3 output.mp3'
		return
	fi
	ffmpeg -i "concat:$1|$2" -acodec copy "$3"
}

### Images

shrinkimage() {
	if [ -z "$1" ] ; then
		echo 'Usage: shrinkimage src dest size'
		return
	fi
	convert "$1" -resize x"$3" "$2"
}

# adds a dropshadown to an image
dropshadow () {
	if [ -z "$1" ] ; then
        echo 'Usage: dropshadow filename.png'
        return
    fi

    filename=$(basename -- "$1")
    # extension="${filename##*.}"
    basename="${filename%.*}"
    # we want to enforce png (even if .jpg as input)
    suffix=".png"
    convert "$1" \( +clone -background black -shadow 50x10+5+5 \) +swap -background none -layers merge +repage "$basename$suffix"
}

#### PDF
# requires ghostscript (gs)
# usage: compresspdf <pdf filename>
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
alias resume="cd ~/projects/portfolio/public/assets"

flatten-pdf() {
	if [ -z "$1" ] ; then
		echo 'Usage: flatten-pdf existing.pdf flattened.pdf'
		return
   	fi
	convert -density 150 $1 $2
}
###### End of PDF


#### pihole

ssh-update-pihole-config() {
	cd "$HOME/projects/pihole-dotfiles"
	just ssh-update-config
	cd -
}


### end of pihole
