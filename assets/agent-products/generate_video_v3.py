#!/usr/bin/env python3
"""
Generate 10-second tech intro video with two images, compressed subtitles and voice.
"""
import os
import subprocess
import asyncio
import edge_tts

ASSETS = "/ya/Code/tanghan/portfolio/assets/agent-products"
IMG1 = f"{ASSETS}/new_img1_shelf.png"
IMG2 = f"{ASSETS}/new_img2_sku.png"
OUTPUT = f"{ASSETS}/tech_intro_video_v3.mp4"
AUDIO = f"{ASSETS}/tech_intro_audio_v3.mp3"
ASS_FILE = f"{ASSETS}/tech_intro_v3.ass"

# Compressed narration for 10 seconds (faster rate)
NARRATION = "多智能体商品识别系统，输入货架图像，自动检测商品位置，质量评估过滤模糊图片，特征检索匹配商品库，OCR联合分辨相似品，最终输出SKU编码，实现智能识别。"

# ASS subtitles compressed to 10 seconds
ASS_CONTENT = """[Script Info]
Title: Tech Intro V3
ScriptType: v4.00+
PlayResX: 1280
PlayResY: 720

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,Arial,32,&H00FFFFFF,&H000000FF,&H00000000,&H80000000,1,0,0,0,100,100,0,0,1,2,1,2,20,20,20,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
Event: 0,0:00:00.00,0:00:01.50,Default,,0,0,0,,多智能体商品识别系统
Event: 0,0:00:01.50,0:00:03.00,Default,,0,0,0,,输入货架图像，自动检测商品位置
Event: 0,0:00:03.00,0:00:04.50,Default,,0,0,0,,质量评估过滤模糊图片
Event: 0,0:00:04.50,0:00:06.00,Default,,0,0,0,,特征检索匹配商品库
Event: 0,0:00:06.00,0:00:07.50,Default,,0,0,0,,OCR联合分辨相似品
Event: 0,0:00:07.50,0:00:10.00,Default,,0,0,0,,最终输出SKU编码，实现智能识别
"""

async def generate_voice():
    """Generate fast voice narration."""
    print("Generating voice narration (fast rate)...")
    communicate = edge_tts.Communicate(NARRATION, "zh-CN-YunxiNeural", rate="+30%")
    await communicate.save(AUDIO)
    print(f"Audio saved: {AUDIO}")

def create_image_clip(img_path, duration, output_path, width=1280, height=720):
    """Create a static image clip with slight Ken Burns effect."""
    print(f"Creating clip from {os.path.basename(img_path)} ({duration}s)...")
    cmd = [
        'ffmpeg', '-y',
        '-loop', '1', '-i', img_path,
        '-vf', f"scale={width}:{height},zoompan=z='min(zoom+0.0005,1.05)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d={int(duration*25)}:s={width}x{height}:fps=25",
        '-t', str(duration),
        '-c:v', 'libx264',
        '-pix_fmt', 'yuv420p',
        '-r', '25',
        output_path
    ]
    subprocess.run(cmd, capture_output=True)
    print(f"  -> {output_path}")

def main():
    # Step 1: Generate voice
    asyncio.run(generate_voice())
    
    # Step 2: Write ASS file
    with open(ASS_FILE, 'w', encoding='utf-8') as f:
        f.write(ASS_CONTENT)
    print(f"ASS subtitles saved: {ASS_FILE}")
    
    # Step 3: Create image clips
    clip1 = f"{ASSETS}/clip1.mp4"
    clip2 = f"{ASSETS}/clip2.mp4"
    create_image_clip(IMG1, 5.0, clip1)
    create_image_clip(IMG2, 5.0, clip2)
    
    # Step 4: Concat clips
    concat_file = f"{ASSETS}/concat_list.txt"
    with open(concat_file, 'w') as f:
        f.write(f"file '{clip1}'\n")
        f.write(f"file '{clip2}'\n")
    
    combined = f"{ASSETS}/combined.mp4"
    cmd = ['ffmpeg', '-y', '-f', 'concat', '-safe', '0', '-i', concat_file, '-c', 'copy', combined]
    subprocess.run(cmd, capture_output=True)
    print("Clips combined")
    
    # Step 5: Burn subtitles and add audio
    cmd = [
        'ffmpeg', '-y',
        '-i', combined,
        '-i', AUDIO,
        '-vf', f"subtitles={ASS_FILE}:force_style='FontName=Arial,FontSize=32,PrimaryColour=&H00FFFFFF,OutlineColour=&H00000000,Bold=1,Outline=2,Shadow=1,Alignment=2,MarginV=20'",
        '-c:a', 'aac',
        '-shortest',
        OUTPUT
    ]
    subprocess.run(cmd, capture_output=True)
    print(f"\nFinal video: {OUTPUT}")
    
    # Cleanup
    for f in [clip1, clip2, concat_file, combined, AUDIO]:
        if os.path.exists(f):
            os.remove(f)
    
    # Check output
    size = os.path.getsize(OUTPUT)
    print(f"Size: {size/1024/1024:.1f} MB")

if __name__ == "__main__":
    main()
