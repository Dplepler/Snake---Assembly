;SNAKE - DAVID PLEPLER
IDEAL
MODEL small
STACK 100h
DATASEG
	
	
x dw 160
y dw 100

snakeIndex dw 0

color db 0Fh

candyColor db 0Ch

;4 is the Default snake size
snakeArray dw 256 dup(0)
snakeSize dw 4 

dir db 's'

xFood dw 0
yFood dw 0

newFood db 0
grow db 0

oneMore dw 0 ;This is to add one more number to si when growing

Clock EQU es:6Ch

loseMessage db 'You lost :( (Press r to continue)', '$'
	
CODESEG

start:

	mov ax, @data
	mov ds, ax
	
	;Switching to Video Graphic Array  
	mov ax, 13h
	int 10h
	
	;;;;;;;;;;;;;;;;code
	call game
	
proc game

snake:
		
	mov bx, offset snakeArray ;Putting array in bx
	
	
	;Putting all 4 positions of the snake in the array
	;Starting from the tail to the head
	mov dx, [x]
	add dx, 3
	mov [bx], dx
	mov dx, [y]
	mov [bx + 2], dx
	
	mov dx, [x]
	add dx, 2
	mov [bx + 4], dx
	mov dx, [y]
	mov [bx + 6], dx
	
	mov dx, [x]
	add dx, 1
	mov [bx + 8], dx
	mov dx, [y]
	mov [bx + 10], dx
	
	mov dx, [x]
	mov [bx + 12], dx
	mov dx, [y]
	mov [bx + 14], dx
		
		
		
randomNum:
		
		  
		
randomX:
	mov ax, 40h
	mov es, ax
	mov ax, [Clock]    
	and al, 00000111b  ;random num between 0 - 7
	mov cl, al
	mov ax, 30
	mul cl ;random num between 0 - 70
	
	cmp ax, 0 ;If the random number is equal to 0 I want to load another random number
	je randomX
	
	mov [xFood], ax ;Put random number inside randomX
				
randomY:
	
	mov ax, 40h
	mov es, ax
	mov ax, [Clock]    
	and al, 00000111b  ; Random num between 0 - 7
	mov cl, al
	mov ax, 30
	mul cl ; Random num between 0 - 70
	
	cmp ax, 0 ; If the random number is equal to 0 I want to load another random number
	je randomY
	
	mov [yFood], ax
	
	; Check if the position of the candy is on the snake, find different location
	mov bh, 0
	mov cx, [xFood]
	mov dx, [yFood]
	mov ah, 0Dh
	int 10h
	cmp al, [color]
	je randomNum
	
	
	
	jmp drawCandy
				
				
drawCandy:

	mov cx, [xFood] ; X
	mov dx, [yFood] ; Y
	mov al, [candyColor]
	mov bh, 0
	mov ah,0Ch
	int 10h
	
	mov [newFood], 0
	
	mov cx, [snakeSize] ; Amount of times to loop
	
	jmp draw
	
draw:

	cmp [newFood], 1
	je randomNum
	

	push cx ; Saving cx value in stack to loop
	
	; Every x and y takes 2 bytes, therefore to get to the next x in the array
	; we will need to add 4 to the index.. 
	; Printing snake
	mov si, [snakeIndex]
	mov cx, [bx + si] ; X
	mov dx, [bx + si + 2] ; Y
	mov al, [color]
	mov bh, 0
	mov ah,0Ch
	int 10h
	
	

	add [snakeIndex], 4

	pop cx ;Putting cx loop value back to cx

	loop draw
	jmp input ;Checking input
			
input:


	mov [snakeIndex], 0 ;Resetting Index value
	

	;Checking for input
	mov al, 0
	mov ah, 1h 
	int 16h
	jnz keyPressed ;If input pressed, check what was pressed
	xor dl, dl
	jmp move
	
	
keyPressed:
	mov ah, 0
	int 16h ;input
	
	mov [dir], al ;Putting input value in dir

	
	jmp move
			
;Checking what value was pressed, if nothing, default is d (left)
move:


	;Delay
	mov ax, 40h
	mov es, ax
	mov ax, [Clock]
	mov cx, 1
		
DelayLoop:                 ;This is delay so that we will see the silky smooth snake move
	mov ax, [Clock]
	
Tick:
	cmp ax, [Clock]
	je Tick
	loop DelayLoop
		

	mov cx, [snakeSize] ;Preparing for another loop
	;Multiplying cx by 2, because we want to take care of both x and y while moving
	mov ax, 2
	mul cx
	mov cx, ax 
	
	push cx
	
	cmp [dir], 'w'
	je UP
	cmp [dir], 's'
	je DOWN
	cmp [dir], 'a'
	je LEFT
	cmp [dir], 'd'
	je RIGHT
			
UP:
	dec [y] ;Moving up
	jmp collision
DOWN:
	inc [y] ;Moving down
	jmp collision
LEFT:
	dec [x] ;Moving left
	jmp collision
RIGHT:  
	inc [x] ;Moving right
	jmp collision
	
collision:
	mov bh, 0
	mov cx, [x]
	mov dx, [y]
	mov ah, 0Dh
	int 10h

	cmp al, [candyColor]
	je foodFlag
	
	cmp al, [color]
	je lose
	
	
	jmp deleteLastPixel
				
				
				
foodFlag:

	mov [newFood], 1
	
	inc [snakeSize] 
	
	inc [oneMore]
	
	mov [grow], 1
			
			
deleteLastPixel:

	mov cx, [bx] ;X
	mov dx, [bx + 2] ;Y
	mov al, 0 ;black
	mov bh, 0
	mov ah, 0Ch
	int 10h
	
	pop cx	

	cmp [grow], 1
	je head
	jmp update
				
update:

	;Shift every index in the array to the left
	mov si, [snakeIndex]
	mov dx, [bx + si + 4]
	mov [bx + si], dx

	add [snakeIndex], 2
	
	loop update

head:

	;Add head 
	mov si, [snakeSize]
	mov ax, 3
	mul si
	mov si, ax
	add si, [oneMore]
	mov dx, [x]
	mov [bx + si], dx ;Last variable in array X
	mov dx, [y]
	mov [bx + si + 2], dx ;Last variable in array Y
	
	mov [snakeIndex], 0 ;Reset snakeIndex
	
	mov cx, [snakeSize] ;Get ready for another loop
	
	mov [grow], 0

	jmp draw
					
lose:
	;Checking for input
	mov al, 0
	mov ah, 1h 
	int 16h
	jnz Restart ;If input pressed, check what was pressed
	xor dl, dl
	
	
	mov ah, 2
	mov bh, 0
	mov dx, 0C10h
	int 10h

	mov ah, 9
	lea dx, [loseMessage]
	int 21h
	
	jmp lose

Restart:
	mov ah, 0
	int 16h ;input
	
	mov [snakeIndex], 0
	
	mov cx, 255
	
	mov [dir], 's'
	
	cmp al, 'r'
	je exit
	
	jmp lose
			
	
endp game

exit:
	;Clearing the array
	mov bx, offset snakeArray
	
	mov [bx + snakeIndex], 0
	inc [snakeIndex]
	loop exit
	
	;Clearing screen
	mov ax, 13h
	int 10h
	
	;Resetting some values
	mov [x], 160
	mov [y], 100
	mov [snakeSize], 4
	
	jmp start ;Restart

	mov ax, 4c00h
	int 21h
END start


