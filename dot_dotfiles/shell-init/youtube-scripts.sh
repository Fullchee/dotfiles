# YouTube/yt-dlp utilities

_yt-dlp() {
	local flags
	flags=("--embed-metadata" "--sponsorblock-remove" "default" "-o" "$HOME/Desktop/YouTube/%(title)s.%(ext)s")

	# Extract custom flags before URLs
	while [[ "$1" == -* ]]; do
		flags+=("$1")
		shift
	done

	mkdir -p ~/Desktop/YouTube
	for url in "$@"; do
		command yt-dlp "${flags[@]}" "$url" &
	done
	wait
}

youtube-best-audio() {
	if [ -z "$1" ]; then
		echo 'Usage: youtube-best-audio url1 url2 url3 ...'
		return
	fi
	_yt-dlp -f "ba[ext=webm]" -x --audio-format opus "$@"
}
alias y3-best=youtube-best-audio

youtube-worst-audio() {
	if [ -z "$1" ]; then
		echo 'Usage: youtube-worst-audio url1 url2 url3 ...'
		return
	fi
	_yt-dlp --extract-audio --audio-format mp3 --audio-quality worst --parse-metadata "title:%(title)s.replace(r' \[[a-zA-Z0-9_-]{11}\]$', '')" "$@"
}
alias y3=youtube-worst-audio

youtube-worst-video() {
	_yt-dlp -f "b[filesize_approx<50M]" --no-playlist "$@" ||
		_yt-dlp -f "b[height<=400]" --no-playlist "$@" ||
		_yt-dlp -f "b" --no-playlist "$@"
}
alias y4=youtube-worst-video
