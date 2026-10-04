# this code written by ai
# ai link : https://deepai.org/chat/deepseek-v4-flash#8c890436-f57a-47e1-9fd6-d6994d96bf27

extends TextureRect

@export_category("round image corner")
@export_range(0, 500) var rightTop: int = 50
@export_range(0, 500) var leftTop: int = 50
@export_range(0, 500) var leftBottom: int = 50
@export_range(0, 500) var rightBottom: int = 50


func _ready() -> void:
    if texture == null:
        return
    
    var image: Image = texture.get_image()
    image.convert(Image.FORMAT_RGBA8)
    var image_size: Vector2i = image.get_size()
    
    # Round all four corners
	# image original point = (0,0) not (1,1) so if img size = 720 the godot range is (0 ..... 719)
    _round_corner(image, Vector2i(0, 0), leftTop)                                  # Top-left
    _round_corner(image, Vector2i(image_size.x - 1, 0), rightTop)                 # Top-right
    _round_corner(image, Vector2i(0, image_size.y - 1), leftBottom)               # Bottom-left
    _round_corner(image, Vector2i(image_size.x - 1, image_size.y - 1), rightBottom) # Bottom-right
    
    texture = ImageTexture.create_from_image(image)


func _round_corner(img: Image, corner: Vector2i, radius: int) -> void:
    if radius < 1:
        return
    
    var image_size: Vector2i = img.get_size()	#this called to avoid indirect access delay and performance issue
    
    # Loop over the corner's bounding box
    for y in range(radius):
        for x in range(radius):
            # Determine the actual image pixel position
            var px: int
            var py: int
            
            # Flip x based on which side (left or right) the corner is on
            if corner.x == 0:
                px = x
            else:
                px = corner.x - x
            
            # Flip y based on which side (top or bottom) the corner is on
            if corner.y == 0:
                py = y
            else:
                py = corner.y - y
            
            # Check if out of bounds (in case radius exceeds image size)
            if (px < 0) or (py < 0) or (px >= image_size.x) or (py >= image_size.y):
                continue
				#If any of these are true, the pixel is outside → continue (skip it).

            
            # Distance from the corner's center point
			# do determine the distance between 2 point we use the formula (Pythagorean distance)
			# the formula equals (d)^2 = (X2-X1)^2 + (Y2-Y1)^2
            var dx: float = float(x - radius)	# Step 1: Find the offset from the center
            var dy: float = float(y - radius)
            var dist_sq: float = dx * dx + dy * dy	#don't use square root cause this way is faster
            # dist_sq = (x)^2 + (y)^2

			#Why squared instead of the actual distance?
			#This is a clever optimization! To check if a pixel is inside the circle, you compare:
			#Normal way: sqrt(dx² + dy²) < radius , slow
			#Squared way: dx² + dy² < radius² , fast


            # If outside the circle , make transparent
            if dist_sq > radius * radius:	# (d)^2 > (r)^2
                var color: Color = img.get_pixel(px, py)	#get pixel color
                color.a = 0.0	#set alpha of that pixel to 0 means transparent
                img.set_pixel(px, py, color)	#replace old pixel with new one


# Optional: re-round corners when the size changes
func _on_resized() -> void:
    _ready()