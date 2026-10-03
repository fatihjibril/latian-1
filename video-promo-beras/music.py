import wave, struct, math, random
sr=44100; T=30; N=sr*T
buf=[0.0]*N
def note(f,start,dur,amp,decay=2.5):
    s=int(start*sr); n=int(dur*sr)
    for i in range(n):
        if s+i>=N: break
        t=i/sr; env=math.exp(-decay*t)*min(1,t*80)
        v=sum(math.sin(2*math.pi*f*k*t)/k**1.6 for k in (1,2,3,4))
        buf[s+i]+=amp*env*v
def hz(m): return 440*2**((m-69)/12)
chords=[[60,64,67],[57,60,64],[53,57,60],[55,59,62]]
bar=2.0
for b in range(int(T/bar)):
    c=chords[b%4]; t0=b*bar
    note(hz(c[0]-12),t0,bar,0.18,1.2)
    for j,step in enumerate([0,1,2,1,0,1,2,1]):
        note(hz(c[step]+12 if j in (2,6) else c[step]),t0+j*bar/8,0.9,0.07,3.5)
    if b%2==0: note(hz(c[2]+12),t0+bar*0.75,1.2,0.05,2)
m=max(abs(x) for x in buf)
w=wave.open('music.wav','w'); w.setnchannels(1); w.setsampwidth(2); w.setframerate(sr)
fr=bytearray()
for i,x in enumerate(buf):
    g=min(1,i/(sr*1.0),(N-i)/(sr*2.5))
    fr+=struct.pack('<h',int(x/m*0.6*g*32767))
w.writeframes(bytes(fr)); w.close()
