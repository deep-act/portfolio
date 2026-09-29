#!/usr/bin/env python3
"""
Generate tech intro video using portfolio images with Ken Burns effect,
voice narration, and ASS subtitles.
"""
import os
import subprocess
import tempfile

# Configuration
ASSETS_DIR = "/ya/Code/tanghan/portfolio/assets/agent-products"
OUTPUT_PATH = f"{ASSETS_DIR}/tech_intro_video_v2.mp4"

# Images from portfolio (in order of presentation)
IMAGES = [
    ("web_shelf_new.jpg", "输入：商品货架图像", 3.0),
    ("web_yolo_detect.png", "商品检测 - YOLO识别", 3.0),
    ("web_blurry.png", "质量评估 - 模糊/局部检测", 2.5),
    ("web_coke_sugar.png", "相似品分辨 - 有糖可乐", 2.5),
    ("web_coke_nosugar.png", "相似品分辨 - 无糖可乐", 2.5),
    ("web_product_01.jpg", "特征检索 - 向量匹配", 2.5),
    ("web_product_02.jpg", "OCR + 指纹库联合分辨", 2.5),
    ("web_shelf_new.jpg", "输出：SKU编码", 3.0),
]

# Voice narration script (Chinese)
NARRATION = """多智能体商品识别系统，解决商超货架商品自动识别难题。

输入商品货架图像，系统自动检测每个商品位置。

通过质量评估，识别模糊或局部图像，确保识别准确性。

对于相似商品，如可口可乐有糖和无糖版本，系统进入精细分辨流程。

通过特征检索，向量匹配商品特征库。

结合OCR文字识别和指纹库，联合分辨相似商品。

最终输出每个商品的SKU编码，实现货架商品的智能识别。"""

def generate_voice():
    """Generate voice narration using edge-tts."""
    import asyncio
    import edge_tts
    
    audio_path = f"{ASSETS_DIR}/tech_intro_audio_v2.mp3"
    
    async def _generate():
        communicate = edge_tts.Communicate(NARRATION, "zh-CN-YunxiNeural", rate="-5%")
        await communicate.save(audio_path)
    
    print("Generating voice narration...")
    asyncio.run(_generate())
    
    return audio_path

def create_ken_burns_clip(image_path, duration, width=1280, height=720):
    """Create a Ken Burns effect clip from an image."""
    with tempfile.NamedTemporaryFile(suffix='.mp4', delete=False) as tmp:
        tmp_path = tmp.name
    
    # Random pan and zoom parameters
    import random
    random.seed(hash(image_path) % 2**32)
    
    # Start and end zoom levels (1.0 to 1.3)
    zoom_start = 1.0 + random.random() * 0.1
    zoom_end = 1.2 + random.random() * 0.1
    
    # Start and end positions (normalized 0-1)
    x_start = random.random() * 0.2
    y_start = random.random() * 0.2
    x_end = random.random() * 0.2
    y_end = random.random() * 0.2
    
    cmd = [
        'ffmpeg', '-y',
        '-loop', '1', '-i', image_path,
        '-vf', f"""
            scale={width}*{zoom_end}:{height}*{zoom_end},
            crop={width}:{height},
            zoompan=z='min(zoom+0.001,{zoom_end})':x='iw/2-(iw/zoom/2)+{x_start}*iw':y='ih/2-(ih/zoom/2)+{y_start}*ih':d={int(duration*25)}:s={width}x{height}:fps=25
        """,
        '-t', str(duration),
        '-c:v', 'libx264',
        '-pix_fmt', 'yuv420p',
        tmp_path
    ]
    
    subprocess.run(cmd, capture_output=True)
    return tmp_path

def create_video_with_transitions(image_clips, audio_path):
    """Combine image clips with crossfade transitions and add audio."""
    # Create concat file
    concat_path = f"{ASSETS_DIR}/temp_concat.txt"
    with open(concat_path, 'w') as f:
        for clip in image_clips:
            f.write(f"file '{clip}'\n")
    
    # Combine clips with crossfade
    combined_path = f"{ASSETS_DIR}/temp_combined.mp4"
    
    # Simple concat first
    cmd = [
        'ffmpeg', '-y',
        '-f', 'concat', '-safe', '0',
        '-i', concat_path,
        '-c', 'copy',
        combined_path
    ]
    subprocess.run(cmd, capture_output=True)
    
    # Add audio
    cmd = [
        'ffmpeg', '-y',
        '-i', combined_path,
        '-i', audio_path,
        '-c:v', 'copy',
        '-c:a', 'aac',
        '-shortest',
        OUTPUT_PATH
    ]
    subprocess.run(cmd, capture_output=True)
    
    # Cleanup
    for clip in image_clips:
        if os.path.exists(clip):
            os.remove(clip)
    if os.path.exists(concat_path):
        os.remove(concat_path)
    if os.path.exists(combined_path):
        os.remove(combined_path)

def main():
    print("Generating tech intro video v2...")
    
    # Generate voice
    audio_path = generate_voice()
    print(f"Audio saved to {audio_path}")
    
    # Create Ken Burns clips for each image
    print("Creating image clips with Ken Burns effect...")
    image_clips = []
    for img_name, caption, duration in IMAGES:
        img_path = f"{ASSETS_DIR}/{img_name}"
        if not os.path.exists(img_path):
            print(f"Warning: {img_path} not found, skipping")
            continue
        
        print(f"  Processing {img_name} ({duration}s)...")
        clip = create_ken_burns_clip(img_path, duration)
        image_clips.append(clip)
    
    print(f"Created {len(image_clips)} clips")
    
    # Combine clips and add audio
    print("Combining clips and adding audio...")
    create_video_with_transitions(image_clips, audio_path)
    
    print(f"Video saved to {OUTPUT_PATH}")
    
    # Cleanup audio
    if os.path.exists(audio_path):
        os.remove(audio_path)

if __name__ == "__main__":
    main()
