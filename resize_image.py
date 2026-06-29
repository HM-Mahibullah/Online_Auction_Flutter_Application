from PIL import Image
import os

# Image path
image_path = r"d:\Semister\6th semester\CIT 320 Software Development Project-II\antique-auction-flutter\assets\images\Nazrul.png"

try:
    # Open image
    img = Image.open(image_path)
    print(f"Original size: {img.size}")
    
    # Resize to 400x648
    img_resized = img.resize((400, 648), Image.Resampling.LANCZOS)
    
    # Save optimized
    img_resized.save(image_path, 'PNG', optimize=True)
    
    file_size = os.path.getsize(image_path) / 1024
    print(f"✓ Resized to 400x648px")
    print(f"✓ File size: {file_size:.1f} KB")
    print(f"✓ Ready to use!")
    
except Exception as e:
    print(f"Error: {e}")
