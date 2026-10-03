set -e
IMG=/tmp/claude-0/-home-user-latian-1/d5d5644a-917d-5c57-8c6f-38c6ed5e2e85/images
B=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
R=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
FPS=30
# seg name img crop(w:h:x:y) dur zoom_dir grade title sub
seg() {
  n=$1; img=$2; crop=$3; dur=$4; z=$5; grade=$6; t=$7; s=$8
  fr=$(python3 -c "print(int($dur*$FPS))")
  printf '%s' "$t" > t$n.txt; printf '%s' "$s" > s$n.txt
  if [ "$z" = in ]; then ZE="1+0.0012*on"; else ZE="1.18-0.0012*on"; fi
  ffmpeg -y -loglevel error -loop 1 -i $IMG/$img -vf "crop=$crop,scale=2560:1440:flags=lanczos,${grade}zoompan=z='$ZE':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=$fr:s=1280x720:fps=$FPS,unsharp=5:5:0.6,\
drawbox=y=ih-210:w=iw:h=210:color=black@0.45:t=fill,\
drawtext=fontfile=$B:textfile=t$n.txt:fontsize=56:fontcolor=white:x=60:y=h-180:alpha='min(1,max(0,(t-0.4)/0.6))':shadowcolor=black@0.6:shadowx=2:shadowy=2,\
drawtext=fontfile=$R:textfile=s$n.txt:fontsize=34:fontcolor=0xFFE9A8:x=60:y=h-105:alpha='min(1,max(0,(t-0.9)/0.6))'" \
  -t $dur -pix_fmt yuv420p -c:v libx264 -preset medium -crf 18 s$n.mp4
}
seg 1 1.png 376:211:250:206 5.5 in "eq=saturation=1.05:brightness=0.02," "Pagi di sawah desa" "Bibit padi ditanam dengan sabar"
seg 2 1.png 360:203:60:70 5.5 in "" "Merawat padi setiap hari" "Dijaga dari hama, dirawat sepenuh hati"
seg 3 1.png 226:127:400:290 5.0 out "eq=saturation=1.15," "Tumbuh subur & sehat" "Air jernih dan tanah desa yang subur"
seg 4 1.png 240:135:386:150 5.5 in "hue=h=-42:s=0.95,colorbalance=rm=0.04:gm=0.02:bm=-0.10,eq=brightness=0.02:saturation=1.0:gamma=1.05," "Saatnya panen!" "Bulir padi bernas, hasil terbaik"
seg 5 2.png 500:281:0:30 5.5 in "" "Dari desa, langsung ke kota" "Segar sampai ke dapur Anda"
# end card
printf 'BERAS DESA' > e1.txt; printf 'Pulen  •  Wangi  •  Asli dari Petani' > e2.txt; printf 'Pesan sekarang!' > e3.txt
ffmpeg -y -loglevel error -loop 1 -i $IMG/1.png -vf "scale=1280:720,boxblur=18:2,eq=brightness=-0.25,\
drawtext=fontfile=$B:textfile=e1.txt:fontsize=110:fontcolor=0xFFD45A:x=(w-tw)/2:y=210:alpha='min(1,t/0.7)':shadowcolor=black@0.7:shadowx=3:shadowy=3,\
drawtext=fontfile=$R:textfile=e2.txt:fontsize=40:fontcolor=white:x=(w-tw)/2:y=360:alpha='min(1,max(0,(t-0.6)/0.7))',\
drawbox=x=440:y=450:w=400:h=80:color=0x2E7D32@0.95:t=fill:enable='gte(t,1.3)',\
drawtext=fontfile=$B:textfile=e3.txt:fontsize=40:fontcolor=white:x=(w-tw)/2:y=470:enable='gte(t,1.3)'" \
  -t 5.5 -r $FPS -pix_fmt yuv420p -c:v libx264 -crf 18 s6.mp4
# xfade chain (0.5s each) -> 30s
ffmpeg -y -loglevel error -i s1.mp4 -i s2.mp4 -i s3.mp4 -i s4.mp4 -i s5.mp4 -i s6.mp4 -filter_complex "\
[0][1]xfade=transition=fade:duration=0.5:offset=5[a];\
[a][2]xfade=transition=fade:duration=0.5:offset=10[b];\
[b][3]xfade=transition=fade:duration=0.5:offset=14.5[c];\
[c][4]xfade=transition=fade:duration=0.5:offset=19.5[d];\
[d][5]xfade=transition=fade:duration=0.5:offset=24.5,format=yuv420p[v]" -map "[v]" -c:v libx264 -crf 20 video.mp4
# soft acoustic-ish pad music (C - Am - F - G), plucked notes
python3 music.py
ffmpeg -y -loglevel error -i video.mp4 -i music.wav -map 0:v -map 1:a -c:v copy -c:a aac -b:a 160k -shortest -t 30 final.mp4
