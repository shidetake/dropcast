#!/bin/bash

DROPBOX_TOKEN=Your_Dropbox_Token
PODCAST_TITLE=title
DROPBOX_BASEDIR=/podcast
RSSNAME=$PODCAST_TITLE.xml.rss

# upload mp3 to Dropbox
for filename in mp3/*.mp3
do
  echo uploading $filename
  curl -s -X POST https://content.dropboxapi.com/2/files/upload \
       --header "Authorization: Bearer $DROPBOX_TOKEN" \
       --header "Dropbox-API-Arg: {\"path\": \"$DROPBOX_BASEDIR/$PODCAST_TITLE/$filename\",\"mode\": \"add\",\"autorename\": true,\"mute\": false,\"strict_conflict\": false}" \
       --header "Content-Type: application/octet-stream" \
       --data-binary @$filename > /dev/null
done

# create RSS header
cat << EOS > $RSSNAME
<?xml version="1.0" encoding="utf-8"?>
<rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" version="2.0">
  <channel>
    <title>$PODCAST_TITLE</title>
EOS

# create RSS body
for filename in mp3/*.mp3
do
  # get shared url
  res=$(curl -s -X POST https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings \
             --header "Authorization: Bearer $DROPBOX_TOKEN" \
             --header "Content-Type: application/json" \
             --data "{\"path\": \"$DROPBOX_BASEDIR/$PODCAST_TITLE/$filename\",\"settings\": {\"requested_visibility\": \"public\"}}")
  url=$(echo $res | jq -r .url | sed -e 's/www.dropbox.com/dl.dropboxusercontent.com/g' | sed -e 's/?dl=0//g')
  length=$(echo $res | jq .size)

  cat << EOS >> $RSSNAME
    <item>
      <title>$(basename $filename .mp3)</title>
      <enclosure url="$url"
                 length="$length"
                 type="audio/mp3" />
      <guid isPermaLink="true">$url</guid>
      <pubDate>$(date -R)</pubDate>
    </item>
EOS
done

# create RSS footer
cat << EOS >> $RSSNAME
  </channel>
</rss>
EOS

# upload RSS to Dropbox
curl -s -X POST https://content.dropboxapi.com/2/files/upload \
     --header "Authorization: Bearer $DROPBOX_TOKEN" \
     --header "Dropbox-API-Arg: {\"path\": \"$DROPBOX_BASEDIR/$PODCAST_TITLE/$RSSNAME\",\"mode\": \"add\",\"autorename\": true,\"mute\": false,\"strict_conflict\": false}" \
     --header "Content-Type: application/octet-stream" \
     --data-binary @$RSSNAME > /dev/null

# get shared url
url=$(curl -s -X POST https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings \
           --header "Authorization: Bearer $DROPBOX_TOKEN" \
           --header "Content-Type: application/json" \
           --data "{\"path\": \"$DROPBOX_BASEDIR/$PODCAST_TITLE/$RSSNAME\",\"settings\": {\"requested_visibility\": \"public\"}}" |
      jq -r .url |
      sed -e 's/www.dropbox.com/dl.dropboxusercontent.com/g' |
      sed -e 's/?dl=0//g')
echo podcast url: $url
