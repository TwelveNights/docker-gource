#!/bin/bash

# Remove previous results
rm -f /results/{gource.ppm,gource.mp4}

# Define defaults
DEPTH="${DEPTH:-24}"
FONT_COLOR="${FONT_COLOR:-FFFF00}"
FONT_SIZE="${FONT_SIZE:-25}"
FPS="${FPS:-30}"
HIDE="${HIDE:-dirnames,filenames}"
RES="${RES:-1920x1080}"
SEC_PER_DAY="${SEC_PER_DAY:-1}"
TITLE="${TITLE:-Example title}"
USER_SCALE="${USER_SCALE:-4.0}"

github_user=''
github_repository=''

# Parse the Github repository string passed as argument and download the repository
prepare_github_repository () {
  repository_string=$1

  counter=$( awk -F'/' '{print NF-1}' <<< "$repository_string" )
  _=$(( counter + 0 ))

   # shellcheck disable=SC2086
  if [ $counter -eq 1 ]; then
    IFS='/' read -ra repository_split <<< "$repository_string"
    github_user="${repository_split[0]}"
    github_repository="${repository_split[1]}"
  else
    echo 'ERROR: Failed to parse the Github repository string'
    # Terminate and indicate error
    exit 1
  fi

  # Download git repository
  git clone "https://github.com/${repository_string}.git" .
}

render () {
  screen -dmS \
    recording \
    xvfb-run -a -s "-screen 0 ${RES}x${DEPTH}" \
    gource "-$RES" \
      -r "$FPS" \
      --title "$TITLE" \
      --user-image-dir /avatars/ \
      --highlight-all-users \
      --seconds-per-day "$SEC_PER_DAY" \
      --hide "$HIDE" \
      --font-size "$FONT_SIZE" \
      --font-colour "$FONT_COLOR" \
      --user-scale "$USER_SCALE" \
      --auto-skip-seconds 1 $EXTRA_OPTS \
      -o /results/gource.ppm

  # This hack is needed because gource process doesn't stop
  lastsize="0"
  filesize="0"

  while [[ "$filesize" -eq "0" || $lastsize -lt $filesize ]]; do
      sleep 20
      lastsize="$filesize"
      filesize=$(stat -c '%s' /results/gource.ppm)
      echo "Polling the size. Current size is ${filesize}"
  done

  echo 'Force stopping recording because file size is not growing'
  screen -S recording -X quit

  xvfb-run -a -s "-screen 0 ${RES}x${DEPTH}" ffmpeg -y -r "$FPS" -f image2pipe \
    -loglevel info -vcodec ppm -i /results/gource.ppm -vcodec libx264 \
    -preset ultrafast -pix_fmt yuv420p -crf 1 -threads 0 -bf 0 /results/gource.mp4

  # Remove the intermediate PPM file
  rm -f /results/gource.ppm
}

# Check if any arguments were passed or if the passed argument is empty
if [ $# -eq 0 ] || [ -z "$1" ]; then
  echo "No arguments supplied. Expecting a volume mounted with the repository."

  # Start the rendering process
  render
else
  # Parse the Github repository string and download the repository
  prepare_github_repository "$1"

  # Start the rendering process
  render

  mv /results/gource.mp4 "/results/${github_user}-${github_repository}.mp4"
fi
