;-----------------------------------------------------------------
;Boucy Ball Simulator (Main code)
;-----------------------------------------------------------------
;Submitted in partial fulfillment of the requirements of 
;The Game Program project for the course 
;Computer Systems Organization (V22.0201)
;Professor Nathan Hall, Fall 2008
;Project due December 21, 2008 (Hull granted an extension)
;
;The user first sees the title of the game and has the option of getting
;	the instructions or just playing the game. 
;
;The game starts with the main playing area which is a light blue rectangle.
;The graphics mode used is 320x200 graphics. There is a 5-pixel border around
;	the playing area that signifies a "wall" in the room where the bouncy
;	ball would be launched. 
;The top left pixel is considered (0,0). The playing area starts at (5,5) and
;	continues for 310 pixels horizontally and 190 pixels. That is how the 
;	5-pixel border is created.  
;
;The first thing the user has to do is decide how fast the ball 
;	should be launched at. They decide this through an animated bar that 
;	displays how fast the user wants the ball to launch at.
;Later on in this program is the method that draws the bar and stops when the 
;	user types in a key to signify that they want to set the speed. 
;
;Then the obstacles are drawn. The user is presented with the ball and the range
;	which the ball can be launched at. The user used the up, down, left, and right
;	arrow key to decide where they want to launch the ball at. 
;When the user presses enter, the location that the ball will launch at is set.
;
;Then the user is presented with the directions to launch the ball at. 
;The user can launch it in 4 different direction, 45 degreees, 135 degrees, 
;	-135 degrees or -45 degrees. They use the 'w' and 's' to cycle between
;	those directions. 
;
;The ball then moves around the room. After hitting a wall or an obstacle, it loses momentum.
;The user gains 1 point for hittig a wall, 2 points for hitting a good obstacle and loses 1 
;	point for hitting a bad obstacle. When the ball loses a certain amount of momentum,
;	the round ends. 
;
;The user gets three rounds to gather up as many points as possible. 
;
        jmp     start		;jumps to beginning of program
;
;These variables are used to run the program in various places
;
LEN	dw 0			;length passed so far
LENT	dw 800			;total length to pass
;
;The following variables are used to draw a rectangle
XMIN	dw 0			;saves x coordinate of top left corner
XLEN	dw 40			;saves horizontal length of rectangle
YMIN	dw 0			;saves y coordinate of top left corner
YLEN	dw 40			;saves vertical length of rectangle
;
;
COLOR   db 00h			;This is used in multiple places to tell 
				;	what color to draw next
;
DIR	DB 0			;This is the direction that the arrow points in that later
				;	determines the direction that the ball will travel
;
;This is used to make the obstacles
NEGX	dw 0			;tells the x and y to add to get the place for the obstacles
NEGY	dw 0
NEWV	dw 0
;
;used to execute the animation
DelX	dw 12			;change in x when animation is happening
DelY	dw 12			;change in y
;
SCORE	db 0			;keeps the score
;
OBSX	dw 0			;placement of obstacle. x coordinate
OBSY	dw 0			;			y coordinate
;
BALLX	dw 160			;tells where to start the ball launching at (x coordinate)
BALLY	dw 100			;		y coordinate
;
DIFF	dw 5			;tells the difficulty level of the game (set as 5, 7, or 9)
				;the difficulty represents the probability of a bad obstacle 
				;appearing. 50% for easy, 70% for medium, 90% for hard
;
;this stores the placement of the obstacles so that the animation can 
;				detect if the obstacle has been hit. 
TOBSP	dw 10 DUP(0)		;stores the top ones
BOBSP	dw 10 DUP(0)		;stores bottom obstacles
LOBSP	dw 10 DUP(0)		;left side obstacles
ROBSP	dw 10 DUP(0)		;right side obstacles
;
;these store the color of each of the obstacles. 
TCOL	dw 10 DUP(0)		;top obstacles
BCOL	dw 10 DUP(0)		;bottom obstacles
LCOL	dw 10 DUP(0)		;left obstacles
RCOL	dw 10 DUP(0)		;right obstacles
;
;these store the index for the information on the next obstacle
TIND	dw 0			;for top obstacle information
BIND	dw 0			;bottom obstacle information
RIND	dw 0			;right obstacle information
LIND	dw 0			;left obstacle information
;
;Used for messages that are displayed during the game
MESS4	db 'S','e','t',' ','S','p','e','e','d'
MESS5	db 'S','c','o','r','e',':'
;
;used when the score is displayed
CHARS	db 6 DUP(0)		;the array for the characters to be printed
;
;stores the messages that are prompts between rounds and after the last round
PROMPT2	db 'Press Enter to start second round','$'
PROMPT3	db 'Press Enter to start final round','$'
PROMPT4	db 'Press N for new game or E to exit','$'
FINAL	db 'Final','$'		;used to display final score
;
RNUM	db 1			;round number
;
;ARRAY VARIBLES AND FILES for the procedure that reads files					
OpenError db 'Intro file not in folder. ','$'
ReadError db 'Error reading intro file. ','$'
buffer 		db 	100 dup (?), '$'
file1		db	'intro.TXT',0,8,'$'		;introductory message when first loaded
file2		db	'intro2.TXT',0,8,'$'		;instructions for playing if user requests it
file3		db	'intro3.TXT',0,8,'$'		;instructions for setting difficulty level
;
;This is the main method that calls the methods
;
start:	call	INTRO		;prints introduction message
	mov	ah, 0		;waits for key press to signify user has finished reading
	int	16h
	cmp	al, 'i'		;sees if they want the instructions on how to play
	je	show2
	cmp	al, 'I'
	jne	next23
show2:	call	PLAYIN		;prints the instructions of they want it
	mov	ah, 0		;waits for user to type something to certify they have finished reading
	int	16h
next23:	cmp	al, 'e'		;sees if user wants to exit
	je	last		;exits if the user wants to
	cmp	al, 'E'
	je	last
newg:	mov	SCORE, 0	;initializes the score for the game
	mov	RNUM, 1		;initializes the round number of the game
	call	SDIFF		;this procedure sets the difficulty
paint:	mov	ax, 0013h
        int     10h		;sets that video mode
	call	SETVARS		;resets the obstacle indicator variables
	call	INNER	
	call	MESS1		;tells user to set speed
	call	BAR		;shows lines in bar
	call	FILLB		;fills the bar
	call	NOBAR		;makes bar disapper
	mov	ah, 0		;waits for user to type something to certify they want to continue
	int	16h
	call	INNER		;prints the background again
	call	OBSA		;print top and bottom obstacles
	call	OBSB		;print left and right obstacles
	call	OBS3		;prints the corner obstacles
	call	LAUNCH		;sets the ball launch
	call	DIREC		;direction for ball to launch in
	call	BALL
	mov	ax, 2		;resets the video mode
	int	10h
	call	MESS2		;tells message between the rounds
	mov	ah, 0		;waits for user to type something before it resets
	int	16h
	cmp	al, 'e'		;sees if they want to exit
	je	last
	cmp	al, 'E'		;sees if they want to exit
	je	last
	inc	RNUM		;goes to next round
	cmp	RNUM, 3		;sees if game is completed
	jbe	paint
	cmp	al, 'n'		;sees if the user wants a new game
	je	newg
	cmp	al, 'N'
	je	newg
last:	int	20h
;
;this gets from the user the difficulty level requested 
SDIFF	PROC
	call	DOPT		;displays options for difficulty level
	mov	ah, 0
	int	16h		;waits for user to type what they want
	cmp	al, '1'		;sees if user wants easy
	je	easy
	cmp	al, '2'		;if user wants medium
	je	medium		
	cmp	al, '3'		;if user wants hard
	je	hard
	jmp	last40
easy:	mov	DIFF, 5
	jmp	last40
medium:	mov	DIFF, 7
	jmp	last40
hard:	mov	DIFF, 9
	jmp	last40
last40:	ret
SDIFF	ENDP
;
;This initializes the variables that reads the placement of the obstacles
SETVARS	PROC
	mov	TIND, 0		;initializes index information
	mov	BIND, 0
	mov	RIND, 0
	mov	LIND, 0
	mov	si, 0
lp34:	mov	TOBSP[si], 0	;initializes placement information
	mov	BOBSP[si], 0
	mov	ROBSP[si], 0
	mov	LOBSP[si], 0	
	mov	TCOL[si], 0	;initializes color information
	mov	BCOL[si], 0
	mov	RCOL[si], 0
	mov	LCOL[si], 0
	inc	si
	cmp	si, 10		;sees if it has gone though the whole array
	jae	last44
	jmp	lp34
last44:	ret
SETVARS	ENDP
;
LAUNCH	PROC
	mov	COLOR, 025h	;border color pink
	call	RANGE		;displays the box that shows the range where the ball can launched from
	call	MOVEC		;moves the ball around
	mov	COLOR, 036h	;sets color back
	call	RANGE		;writes over the box that was made
	mov	ax, 500		;plays sound when user has decided on spot to launch ball at
	mov	dx, 7
	call	NOTE
	ret
LAUNCH	ENDP
;
;
;This displays the message that the bar represents the speed of the ball
MESS1	PROC
	mov	si, 0
	mov	dh, 17		;sets first cursor position
	mov	dl, 10		;
lp26:	mov	ah, 2		;subfunction to set cursor position
	int	10h		;sets cursor position
	mov	cx, 1
	mov	ah, 0ah		;video mode to write char at cursor
	mov	al, MESS4[si]	;character to display
	int	10h
	inc	dl		;next cursor position
	inc	si		;next array index in the reading of the word
	cmp	si, 9		;if end of word has been reached
	jb	lp26
	ret
MESS1	ENDP
;
;This displays the message of the user's score
;
MESS2	PROC
	cmp	RNUM, 3
	jb	next16
	mov	ah, 09h		;displays final if we are at the last screen
	mov	dx, offset FINAL
	int	21h
next16:	mov	si, 0
	mov	ah, 02h		;mode that sets position of cursor
	mov	dx, 0100h	;cursor position
	int	10h		
	mov	ah, 0eh		;sets back video mode
;
;This tells the user the score. It first displays score:
lp25:	mov	al, MESS5[si]	;character to display
	int	10h		;displays the character
	inc	si		;next character
	cmp	si, 6		;if end of word has been reached
	jb	lp25
;
	call	DISP		;calls procedure that displays the numerical score
;
	mov	ah, 02h		;mode that sets cursor
	mov	dx, 0200h	;sets cursor to next line
	int	10h
	cmp	RNUM, 1		;sees which round to jump to in order to see what message to print
	je	rnd2		
	cmp	RNUM, 2
	je	rnd3
	cmp	RNUM, 3
	je	rndx
rnd2:	mov 	ah, 09h		;tells user to press enter to start second round
	mov 	dx, offset PROMPT2
	int 	21h
	jmp	last15
rnd3:	mov 	ah, 09h		;tells user to press enter to start final round
	mov 	dx, offset PROMPT3
	int 	21h
	jmp	last15
rndx:	mov 	ah, 09h		;tells user to press enter to end game
	mov 	dx, offset PROMPT4
	int 	21h
	jmp	last15
last15:	ret
MESS2	ENDP
;
;
;This procedure is used to print out the score. This is copied directly
;	from the Sieve of Erastosthenes program that I made earlier in the class.
;	This is the procedure that takes a hexadecimal number and makes it into a 
;	decimal number.
;The procedure uses the standard algorithm for base conversion
;	to go from base-16 hexadecimal to base-10 decimal
;
DISP	PROC
	jmp     strt        
strt:   mov     cx, 10           ;the base
        mov     dx, 0
        mov     si, 0		 ;array index initialization
	mov	ah, 0
        mov     al, SCORE        ;number to be divided
lpi:    mov     dx, 0            ;resets dx 
        div     cx               ;does division
good:   mov     CHARS[si], dl    ;puts remainder into the array. it's <10, so one byte is fine
        cmp     ax, 0             ;sees if it is finished
        jbe     fi
        inc     si
        jmp     lpi     
fi:     mov     ah, 0eh          ;sets video page for number to be read
dsp:    mov     al, CHARS[si]    ;puts it into the register to be read
        add     al, '0'          ;puts it into ASCII
        int     10h
        cmp     si, 0            ;sees if all of array has been read
        je      fin
        dec     si
        jmp     dsp
fin:    ret
DISP	ENDP
;
;This shows the area where the ball can be launched from
;It draws the box that portrays this. 
;
RANGE	PROC
	mov	XMIN, 15	;left x coord
	mov	YMIN, 15	;top y coord
	mov	XLEN, 289	;length of top/bottom line
	mov	YLEN, 169	;length of left/right line
	call	LINEH		;draws top line
	mov	YMIN, 184	;bottom y coord
	call	LINEH		;draws bottoom line
	mov	YMIN, 15	;back to top y coord
	call	LINEV		;draws left line
	mov	XMIN, 304	;right x coord
	call	LINEV		;draws right line	
	ret
RANGE	ENDP
;
;
;The following method is used to move around the ball so that the user can
;	decide where to launch the ball from. When int 16h is used and the user
;	types in the up, left, down, or right arrow key, a key code is placed
;	in register ah and al is left as 0
;AH Key code for 
;	up arrow: 48h
;	right arrow: 4Dh
;	down arrow: 50h 
;	left arrow: 4Bh
;
MOVEC	PROC
;shows the initial marking spot, which is in the center of the screen
	mov	XLEN, 3		;the ball is 3 pixels wide
	mov	YLEN, 3		;the ball is 3 pixels high
	mov	YMIN, 100	;sets y min as center of screen
	mov	XMIN, 160	;sets x min as center of screen
	mov	COLOR, 02Ah	;sets color as pink
	call	RECT		;draws the ball
;
lp15:	mov	ah, 0		;calls for direction to move it
	int	16h		;gets the input
	cmp	ah, 048h	;sees if user wants it to go up
	je	up
	cmp	ah, 050h	;sees if user wants to go down
	je	down
	cmp	ah, 04Bh	;if user wants to go left
	je	left
	cmp	ah, 04Dh	;if user wants to go right
	je	right
	jmp	last4		;goes to end if user did not input any of that
;
;moves it up one place
;
up:	cmp	YMIN, 16	;sees if at top
	ja	cont1		;lets it move if it is not
	jmp	lp15		;goes back to beginning if it is
cont1:	mov	COLOR, 036h	;sets color as background color
	call	RECT		;so that the last place is painted over
	mov	COLOR, 02Ah	;sets color back to ball color
	sub	YMIN, 1		;makes it moves up
	call	RECT		;draws the ball moved up
	jmp	lp15		;sees what user wants to do next 
				;	in terms of moving the ball
;
;moves it down one place
;
down:	cmp	YMIN, 181	;is it at the bottom?
	jb	cont2		;lets it continue if it is not
	jmp	lp15		;goes back to beginning if it is
cont2:	mov	COLOR, 036h	;paints over last place
	call	RECT		;so that the last place is painted over
	mov	COLOR, 02Ah	;sets color back to ball color
	add	YMIN, 1		;makes it move down
	call	RECT		;draws the ball moved down
	jmp	lp15		;sees what user wants to do next 
				;	in terms of moving the ball
;
;moves it left one place
;
left:	cmp	XMIN, 16	;is it all the way to the left?
	ja	cont3		;lets it continue if it's not
	jmp	lp15		;goes back to beginning if it is
cont3:	mov	COLOR, 036h	;paints over last place
	call	RECT		;so that the last place is painted over
	mov	COLOR, 02Ah	;sets color back to ball color
	sub	XMIN, 1		;makes it move left
	call	RECT		;draws the ball moved left
	jmp	lp15		;sees what user wants to do next 
				;	in terms of moving the ball
;
;moves it right one place
;
right:	cmp	XMIN, 301	;is it all the way to the right?
	jb	cont4		;lets it continue if it's not
	jmp	lp15		;goes back to beginning if it is
cont4:	mov	COLOR, 036h	;paints over last place
	call	RECT		;so that the last place is painted over
	mov	COLOR, 02Ah	;sets color back to ball color
	add	XMIN, 1		;makes it move right
	call	RECT		;draws the ball moved right
	jmp	lp15		;sees what user wants to do next 
				;	in terms of moving the ball
;
;this is called once the placement of the ball has been finalized by the user
;
last4:	mov	COLOR, 036h	;sets color back when user no longer wants to move target
	call	RECT		;paints over final ball placement
	mov	ax, XMIN	;saves the place for the ball to launch at (x coord)
	mov	BALLX, ax
	mov	ax, YMIN	;save place for ball to launch (y coordinate)
	mov	BALLY, ax
	ret
MOVEC	ENDP
;
;DIR determines what quadrant that it points in 
;	Dir = 1 points 45 degrees
;	Dir = 2 points 135 degrees
;	Dir = 3	points -135 degrees
;	Dir = 4 points -45 degrees
;This method calls the methods that prints the respective arrows
;
ARROW	PROC
	cmp	DIR, 1		
	je	D1
	cmp	DIR, 2
	je	D2
	cmp	DIR, 3
	je	D3
	cmp	DIR, 4
	je	D4
	ret
D1:	call 	ARROW1
	ret
D2:	call	ARROW2
	ret
D3:	call	ARROW3
	ret
D4:	call	ARROW4
	ret
ARROW	ENDP
;
ARROW1	PROC
	mov	cx, 15		;length of arrow to cx
	mov	bx, 0		;length of line
	mov     di, 0a000h	;put the video segment into di
        mov     es, di		;so it can be easily put into ds
        xor     di, di		;start writing at coordinates (0,0)
	mov	ax, 320
	mul	BALLY
	mov	di, ax
	add	di, BALLX
lp18:	mov	al, COLOR
	stosb			;writes the pixel to the screen	
	sub	di, 320		;writes next pixel in the line
	inc	bx		;where to continue to
	cmp	bx, cx		;sees if length passed
	jbe	lp18
	ret
ARROW1	ENDP
;
ARROW2	PROC
	mov	cx, 15		;length of arrow to cx
	mov	bx, 0		;length of line
	mov     di, 0a000h	;put the video segment into di
        mov     es, di		;so it can be easily put into ds
        xor     di, di		;start writing at coordinates (0,0)
	mov	ax, 320
	mul	BALLY
	mov	di, ax
	add	di, BALLX
lp19:	mov	al, COLOR
	stosb			;writes the pixel to the screen	
	sub	di, 322		;writes next pixel in the line
	inc	bx		;where to continue to
	cmp	bx, cx		;sees if length passed
	jbe	lp19
	ret
ARROW2	ENDP
;
ARROW3	PROC
	mov	cx, 15		;length of arrow to cx
	mov	bx, 0		;length of line
	mov     di, 0a000h	;put the video segment into di
        mov     es, di		;so it can be easily put into ds
        xor     di, di		;start writing at coordinates (0,0)
	mov	ax, 320
	mul	BALLY
	mov	di, ax
	add	di, BALLX
lp20:	mov	al, COLOR
	stosb			;writes the pixel to the screen	
	add	di, 318		;writes next pixel in the line
	inc	bx		;where to continue to
	cmp	bx, cx		;sees if length passed
	jbe	lp20
	ret
ARROW3	ENDP
;
ARROW4	PROC
	mov	cx, 15		;length of arrow to cx
	mov	bx, 0		;length of line
	mov     di, 0a000h	;put the video segment into di
        mov     es, di		;so it can be easily put into ds
        xor     di, di		;start writing at coordinates (0,0)
	mov	ax, 320
	mul	BALLY
	mov	di, ax
	add	di, BALLX
lp21:	mov	al, COLOR
	stosb			;writes the pixel to the screen	
	add	di, 320		;writes next pixel in the line
	inc	bx		;where to continue to
	cmp	bx, cx		;sees if length passed
	jbe	lp21
	ret
ARROW4	ENDP
;
;The next method gets the input from the user as to which direction to point to
;the key 'w' tells the arrow to rotate counter-clockwise
;key 's' tells arrow to rotate clock-wise
;
DIREC	PROC
	mov	COLOR, 030h	;moves color into the variable
	mov	DIR, 1		;initial direction is 45 degree angle
	call 	ARROW		;prints the 45 degree arrow
lp22:	mov	ah, 0		;mode that waits for user to type input
	int	16h
	cmp	al, 'w'		;if user wants to go counter clockwise
	je	addone
	cmp	al, 's'		;to go clockwise
	je	subone
	jmp	result		;returns if user types another key
;
;rotates arrow counter-clockwise
;
addone:	mov	COLOR, 036h	;background color
	call	ARROW		;paints over last arrow
	inc	DIR
	cmp	DIR, 4		;sees if it has reached the last direction
	jbe	next5		;if it has not, then continues
	mov	DIR, 1		;cycles back to beginning if it has reached end
next5:	mov	COLOR, 030h	;sets color back
	call	ARROW		;makes the new arrow
	jmp	lp22
;
;rotates arrow clock-wise
;
subone:	mov	COLOR, 036h
	call	ARROW		;paints over last arrow
	dec	DIR
	cmp	DIR, 1		;if it has reached end on other side
	jae	next6		;continues if it has has not 
	mov	DIR, 4		;goes to end on other side if necessary
next6:	mov	COLOR, 030h	;sets color back
	call	ARROW
	jmp	lp22
;
;This then translates the results of the user's actions
;
result:	cmp	DIR, 1		;if direction is in 45 degree angle
	jne	nxt1
	neg	DelY		;negates delta y in this case
	jmp	lst
nxt1:	cmp	DIR, 2		;if direction is in 135 degree angle
	jne	nxt2
	neg	DelX		;negates both change in x and change in y
	neg	DelY
	jmp	lst
nxt2:	cmp	DIR, 3			
	jne	lst		;at this point, DelX and DelY shouldn't be change
	neg	DelX
	jmp	lst
lst:	mov	COLOR, 036h	;background color so that arrow is erased
	call	ARROW
	mov	ax, 750		;frequencey for launch beep (same as beep off paddle in Dewar Program)
	mov	dx, 7
	call	NOTE		;launch beep
	ret
DIREC	ENDP
;
;This procedure is used to print the introduction file. This file is the first file that 
;	the user sees when they launch the game. 
;From another source: fellow student in class Fatima Rivera	
;
INTRO	PROC
	mov	dx, offset file1
	mov 	ah, 3dh		;DOS function to open a file
	int 	21h 		;open the file
	jc 	openE	 	;if opening error, display error
	mov 	bx, ax		;save  file handle to bx because read procedure will need it
plp:	mov 	ah, 3fh		;DOS function to read file
	lea 	dx, buffer
	mov 	cx, 100		;number of bytes to read
	int 	21h
	jc 	readE			; if error
	mov 	si, ax			;number of bytes read
	mov 	buffer[si], '$'		;need $ to print buffer array
	mov 	dx, offset buffer	;buffer is the array to read
	mov 	ah, 09h			;DOS function to print file
	int 	21h 			;print on screen now!
	cmp 	si, 100			;check amt of data read
	je 	plp 			;not done reading, read more
	jmp 	stop			;done reading, jump to end
openE:	mov 	ah, 09h			;prints the error message if error reading file
	mov 	dx, offset OpenError
	int 	21h
	jmp 	stop 
readE:	mov 	ah, 09h			;prints error message if no file is found
	mov 	dx, offset ReadError
 	int 	21h
stop:	ret
INTRO	ENDP
;
;This procedure is used to display the instructions on how to play if the user requests them. 
;It is almost the same as the procedure above
;
PLAYIN	PROC
	mov	dx, offset file2
	mov 	ah, 3dh		;DOS function to open a file
	int 	21h 		;open the file
	jc 	openEe	 	;if opening error, display error
	mov 	bx, ax		;save  file handle to bx because read procedure will need it
plpa:	mov 	ah, 3fh		;DOS function to read file
	lea 	dx, buffer
	mov 	cx, 100		;number of bytes to read
	int 	21h
	jc 	readEe			; if error
	mov 	si, ax			;number of bytes read
	mov 	buffer[si], '$'		;need $ to print buffer array
	mov 	dx, offset buffer	;buffer is the array to read
	mov 	ah, 09h			;DOS function to print file
	int 	21h 			;print on screen now!
	cmp 	si, 100			;check amt of data read
	je 	plpa 			;not done reading, read more
	jmp 	stop			;done reading, jump to end
openEe:	mov 	ah, 09h			;prints the error message if error reading file
	mov 	dx, offset OpenError
	int 	21h
	jmp 	stopa 
readEe:	mov 	ah, 09h			;prints error message if no file is found
	mov 	dx, offset ReadError
 	int 	21h
stopa:	ret
PLAYIN	ENDP
;
;
;This displays the options for difficulty level
DOPT	PROC
	mov	dx, offset file3
	mov 	ah, 3dh		;DOS function to open a file
	int 	21h 		;open the file
	jc 	openE1	 	;if opening error, display error
	mov 	bx, ax		;save  file handle to bx because read procedure will need it
plp1:	mov 	ah, 3fh		;DOS function to read file
	lea 	dx, buffer
	mov 	cx, 100		;number of bytes to read
	int 	21h
	jc 	readE1			; if error
	mov 	si, ax			;number of bytes read
	mov 	buffer[si], '$'		;need $ to print buffer array
	mov 	dx, offset buffer	;buffer is the array to read
	mov 	ah, 09h			;DOS function to print file
	int 	21h 			;print on screen now!
	cmp 	si, 100			;check amt of data read
	je 	plp1			;not done reading, read more
	jmp 	stop			;done reading, jump to end
openE1:	mov 	ah, 09h			;prints the error message if error reading file
	mov 	dx, offset OpenError
	int 	21h
	jmp 	stop 
readE1:	mov 	ah, 09h			;prints error message if no file is found
	mov 	dx, offset ReadError
 	int 	21h
stop4:	ret
DOPT	ENDP
;
;following method writes multiple obstalces on the top and bottom of the screen
;
OBSA	PROC
	mov	OBSY, 5		;sets y coordinate for top obstacles
	call	OBS1		;prints the top obstacles
	mov	OBSY, 185	;sets y coordinate for bottom obstacles
	call	OBS1		;prints the bottom obstacles
	ret
OBSA	ENDP
;
;following method writes multiple obstalces on the left and right of the screen
;
OBSB	PROC
	mov	OBSX, 5		;sets x coordinate for left obstacles
	call	OBS2		;prints left obstacles
	mov	OBSX, 305	;sets x coordinate for right obstacles
	call	OBS2		;prints right obstacles
	ret
OBSB	ENDP
;
;following method writes multiple obstalces on the top/bottom of the screen
;
OBS1	PROC
	mov	OBSX, 55	;x coordinate on first obstacle
lp12:	mov	ax, 11		;randomly decides where in the interval to draw the rectangle
	int	62h		;generates random number
	add	OBSX, ax	;adds random number generated
	push	ax		;saves number
	call	OBS		;draws good obstacle
	pop	ax		;puts obsx back to normal
	sub	OBSX, ax
	add	OBSX, 40	;goes to next place, 40 pixels later
	cmp	OBSX, 280	;sees if at end of screen
	jb	lp12		;if it hasn't reached the end yet
	ret
OBS1	ENDP
;
;following method writes multiple obstalces on the left/right of the screen
;
OBS2	PROC
	mov	OBSY, 55	;y coordinate on first obstacle
lp16:	mov	ax, 11		;randomly decides where in the interval to draw the rectangle
	int	62h		;generates random number
	add	OBSY, ax	;adds random number generated
	push	ax		;saves number	
	call	OBS		;draws good obstacle
	pop	ax		;gets it back
	sub	OBSY, ax
	add	OBSY, 40	;goes to next place, 40 pixels down
	cmp	OBSY, 160	;sees if at end of screen
	jb	lp16		;if it hasn't reached end yet
	ret
OBS2	ENDP
;
;This method is used to determine the change in x or y with the corner obstacles
;
NEWXY	PROC
	mov	ax, 2
	int	62h		;randomly generates 1 or 0 to decide if it should change x or y
	mov	NEWV, ax	;moves the result to the variable NEWV
	mov	ax, 11		
	int	62h		;generates 0-10 to tell offset
	cmp	NEWV, 0		;sees what was decided
	je	diffy		;changes y if 0 was attained
	cmp	NEGX, 0		;sees if it has to change x in the negative direction. i.e. sees 
				;	if the obstacle is in the right corners in which case the offsets
				;	would be negative
	je	next3		;if it doesn't then it skips the negation step
	neg	ax		;negates it if it needs to be
next3:	add	OBSX, ax	;changes x coordinate of obstacle by randomly generated offset
	jmp	last2
diffy:	cmp	NEGY, 0		;sees if it has to change y in negative direction
	je	next4
	neg	ax
next4:	add	OBSY, ax	;changes y coordinate of obstacle by randomly generated offset 
last2:	ret
NEWXY	ENDP
;
;following method writes obstacles on the corners of the screen
;
OBS3	PROC
;
;this draws the obstacle in the top left corner
	mov	OBSX, 5		;y coordinate top corner
	mov	OBSY, 5		;x coordinate left corner
	mov	NEGX, 0		;does not need to negate delta x
	mov	NEGY, 0		;doesn't need to negate delta y
	call	NEWXY		;gets a randomly generated offset
	call	OBS		;draws the obstalce
;
;draws the obstacle in the top right corner
	mov	OBSY, 5		;y coordinate top corner
	mov	OBSX, 305	;x coordinate right corner
	mov	NEGX, 1		;needs to negate delta x
	mov	NEGY, 0		;doesn't need to negate delta y
	call	NEWXY		;gets a randomly generated offset
	call	OBS		;draws the obstacle
;
;draws obstacle in bottom left corner
	mov	OBSX, 5		;x coordinate left corner
	mov	OBSY, 185	;y coordinate right corner
	mov	NEGX, 0		;does not need to negate delta x
	mov	NEGY, 1		;needs to negate delta y
	call	NEWXY		;gets a randomly generated offset
	call	OBS		;draws the obstacle
;
;draws obstacle in bottom right corner
	mov	OBSY, 185	;y coordinate bottom corner
	mov	OBSX, 305	;x coordinate right corner
	mov	NEGX, 1		;needs to negate delta x
	mov	NEGY, 1		;needs to negate delta y
	call	NEWXY		;gets a randomly generated offset
	call	OBS		;draws the obstacle	
	ret
OBS3	ENDP
;
;The following method randomly decides the color of the obstacle
;RNG (random number generator) is used here
;color code 02Fh for good obstacle (green). given if RNG produces 0
;color code 070h for bad obstacle (red). given if RNG produces 1
;
GETCOL	PROC
	mov	ax, 10
	int	62h		;randomly generates 0-9
	cmp	ax, DIFF
	jbe	next
	mov	al, 02Fh	;shows it's a good obstacle
	jmp	last1
next:	mov	al, 070h	;shows it's a bad obstacle
last1:	ret
GETCOL	ENDP
;
;This method writes a single obstacle. 
;It uses the random number generator to decide if it should be drawn or not, 
;	Then the random number generator determines its color(red or green)
;
OBS	PROC
;this first determines whether it will actually be drawn
	mov	ax, 10
	int	62h		;randomly generates 0-10 to determine if obstacle should be drawn
	cmp	ax, 3		;if 3 or below is drawn, then obstacle is not drawn
	jbe	nodraw		;skips to end if obstacle won't be drawn
;
;after determining that it will be drawn, it decides the color
	call	GETCOL		;gets whether the obstacle is bad or good (red or green)
	mov	COLOR, al	;sets color
;
;this part then sees where the obstacles lies so that its information can be recorded
	cmp	OBSY, 5		;sees if at the top ones
	je	add1		;add it to obstacle list if it is
	cmp	OBSY, 185	;sees if at the bottom ones
	je	add2		;add to bottom list if it is 
	cmp	OBSX, 5		;sees if it is a left one
	je	add3		;add to left list if it is
	cmp	OBSX, 305	;sees if it is a right one
	je	add4		;add to right list if it is
	jmp	skip1		
;
;these call the methods that add obstacles information to the arrays
add1:	call	ADDT
	jmp	skip1
add2:	call	ADDB
	jmp	skip1
add3:	call	ADDL
	jmp	skip1
add4:	call	ADDR
	jmp	skip1
;
;this finally draws the obstacle
;it is drawn by the rectangle method, so it places the obstacle information
;	into the parameters for the rectangle method
skip1:	mov	ax, OBSX	;puts the x coordinate into XMIN
	mov	XMIN, ax
	mov	XLEN, 10	;puts length of 10 into rectangle length
	mov	ax, OBSY	;puts y coordinate into YMIN
	mov	YMIN, ax
	mov	YLEN, 10	;length of 10 into rectangle length
	call	RECT		;draws the obstacle as a rectangle
nodraw:	ret
OBS	ENDP
;
;This moves information about the obstacle into the array about the ones in the top
;
ADDT	PROC			
	mov	si, TIND	;current index where the new one is to be added	
	mov	ax, OBSX	;adds the new one to the array
	mov	TOBSP[si], ax
	mov	dh, 0
	mov	dl, COLOR	;puts color into the register DX
	mov	TCOL[si], dx	;puts color into array that records it
	add	TIND,2		;goes to next index
	ret	
ADDT	ENDP
;
;This moves information about the obstacle into the array about the ones in the bottom
;
ADDB	PROC			
	mov	si, BIND	;current index where the new one is to be added	
	mov	ax, OBSX	;adds the new one to the array
	mov	BOBSP[si], ax
	mov	dh, 0
	mov	dl, COLOR	;puts color into the register DX
	mov	BCOL[si], dx	;puts color into array that records it
	add	BIND,2		;goes to next index
	ret	
ADDB	ENDP
;
;This moves information about the obstacle into the array about the ones in the left
;
ADDL	PROC			
	mov	si, LIND	;current index where the new one is to be added	
	mov	ax, OBSY	;adds the new one to the array
	mov	LOBSP[si], ax
	mov	dh, 0
	mov	dl, COLOR	;puts color into the register DX
	mov	LCOL[si], dx	;puts color into array that records it
	add	LIND,2		;goes to next index
	ret	
ADDL	ENDP
;
;This moves information about the obstacle into the array about the ones in the right
;
ADDR	PROC			
	mov	si, RIND	;current index where the new one is to be added	
	mov	ax, OBSY	;adds the new one to the array
	mov	ROBSP[si], ax
	mov	dh, 0
	mov	dl, COLOR	;puts color into the register DX
	mov	RCOL[si], dx	;puts color into array that records it
	add	RIND,2		;goes to next index
	ret	
ADDR	ENDP
;
;This method is used to paint over the bar after the user had decided where to launch the ball
;
NOBAR	PROC
	mov	COLOR, 036h	;sets the background color
	mov	XMIN, 80	;sets the parameters of the bar as the parameters
	mov	XLEN, 161	;	for the rectangle procedure
	mov	YMIN, 145	
	mov	YLEN, 11	
	call	RECT		;actually paints over the bar by drawing the rectangle over it
	ret
NOBAR	ENDP
;
;takes in al as color and updates score depending on color of obstacle hit
NEWSCO	PROC
	cmp	al, 02Fh	;if good obstacle
	je	gd1
	cmp	al, 070h	;if bad obstacle
	je	bd1
	jmp	skp20
gd1:	add	SCORE, 2	;good obstacle hit, increases score
	mov	ax, 1500	;frequency for good obstacle hit
	mov	dx, 7
	call	NOTE		;beep for good obstacle
	jmp	skp20
bd1:	dec	SCORE		;bad obstacle hit. decreases score
	mov	ax, 1000	;frequency for bad obstacle hit
	mov	dx, 7
	call	NOTE		;beep for bad obstacle
	jmp	skp20
skp20:	ret
NEWSCO	ENDP
;
;
;checks the top to see if the ball is hitting an obstacle on the top
CHECKT	PROC
	mov	si, 0		;used to go through the array
lp30:	mov	ax, TOBSP[si]	;puts obstacle position into AX register
	sub	ax, 3
	cmp	cx, ax		;sees if more left than left-most possibility
	jb	skp10		;not in interval, so skips ot end
	add	ax, 13		
	push	cx
	cmp	cx, ax		;sees if more right than right-most possibility
	pop	cx
	ja	skp10		;skips to end, b/c it's not in interval
;
;paints over the obstacle if the ball is in its vincinity
;first records that the obstacle has been hit
	mov	TOBSP[si], 000h	;makes place 0 so that it doesn't get read again
	push	si		;saves registers
	push	ax
	mov	ax, TCOL[si]
	call	NEWSCO		;updates the score
	pop	ax		;gets it back from stack
	pop	si
;
;this paints over the obstacle to show it disappearing
	sub	ax, 10		;makes XMIN for rectangle
	mov	XMIN, ax	;parameters for rectangle to be drawn
	mov	XLEN, 10
	mov	YMIN, 5
	mov	YLEN, 10
	mov	COLOR, 036h
	call	RECT		;paints over obstacle
	jmp	skp11
skp10:	add	si, 2
	cmp	si, TIND	;sees if end of array has been reached
	ja	skp11		;if it has been reached
	jmp	lp30		;checks next spot
skp11:	ret
CHECKT	ENDP
;
;checks the bottom to see if the ball is hitting an obstacle on the top
CHECKB	PROC
	mov	si, 0		;used to go through the array
lp31:	mov	ax, BOBSP[si]	;puts obstacle position into AX register
	sub	ax, 3
	cmp	cx, ax		;sees if more left than left-most possibility
	jb	skp13		;not in interval, so skips ot end
	add	ax, 13		
	cmp	cx, ax		;sees if more right than right-most possibility
	ja	skp13		;skips to end, b/c it's not in interval
;
;paints over the obstacle if the ball is in its vincinity
;first, it records that it an obstacle was hit
	mov	BOBSP[si], 000h	;makes place 0 so that it doesn't get read again
	push	ax		;saves registers
	push	si
	mov	ax, BCOL[si]
	call	NEWSCO		;updates the score
	pop	si		;gets it back from stack
	pop	ax
;
;this paints over the obstacle to show it disappearing
	sub	ax, 10		;makes XMIN for rectangle
	mov	XMIN, ax	;parameters for rectangle to be drawn
	mov	XLEN, 10
	mov	YMIN, 185
	mov	YLEN, 10
	mov	COLOR, 036h
	call	RECT
	jmp	skp11
skp13:	add	si, 2
	cmp	si, BIND	;sees if end of array has been reached
	ja	skp12		;if it has been reached
	jmp	lp31		;checks next spot
skp12:	ret
CHECKB	ENDP
;
;checks the left to see if the ball is hitting an obstacle on the top
CHECKL	PROC
	mov	si, 0		;used to go through the array
lp36:	mov	ax, LOBSP[si]	;puts obstacle position into AX register
	sub	ax, 3
	cmp	bx, ax		;sees if more left than left-most possibility
	jb	skp14		;not in interval, so skips ot end
	add	ax, 13		
	cmp	bx, ax		;sees if more right than right-most possibility
	ja	skp14		;skips to end, b/c it's not in interval
;
;paints over the obstacle if the ball is in its vincinity
;first, it records that it an obstacle was hit
	mov	LOBSP[si], 000h	;makes place 0 so that it doesn't get read again
	push	ax		;saves registers
	push	si
	mov	ax, LCOL[si]
	call	NEWSCO		;updates the score
	pop	si		;gets it back from stack
	pop	ax
;
;this paints over the obstacle to show it disappearing
	sub	ax, 10		;makes YMIN for rectange
	mov	YMIN, ax
	mov	YLEN, 10
	mov	XMIN, 5		;parameters for rectangle to be drawn
	mov	XLEN, 10
	mov	COLOR, 036h
	call	RECT
	jmp	skp15
skp14:	add	si, 2
	cmp	si, LIND	;sees if end of array has been reached
	ja	skp15		;if it has been reached
	jmp	lp36		;checks next spot
skp15:	ret
CHECKL	ENDP
;
;checks the right to see if the ball is hitting an obstacle on the top
CHECKR	PROC
	mov	si, 0		;used to go through the array
lp35:	mov	ax, ROBSP[si]	;puts obstacle position into AX register
	sub	ax, 3
	cmp	bx, ax		;sees if more left than left-most possibility
	jb	skp18		;not in interval, so skips ot end
	add	ax, 13		
	cmp	bx, ax		;sees if more right than right-most possibility
	ja	skp18		;skips to end, b/c it's not in interval
;
;paints over the obstacle if the ball is in its vincinity
;first, it records that it an obstacle was hit
	mov	ROBSP[si], 000h	;makes place 0 so that it doesn't get read again
	push	ax		;saves registers
	push	si
	mov	ax, RCOL[si]
	call	NEWSCO		;updates the score
	pop	si		;gets it back from stack
	pop	ax
;
;this paints over the obstacle to show it disappearing
	sub	ax, 10		;makes YMIN for rectange
	mov	YMIN, ax
	mov	YLEN, 10
	mov	XMIN, 305	;parameters for rectangle to be drawn
	mov	XLEN, 10
	mov	COLOR, 036h
	call	RECT
	jmp	skp17
skp18:	add	si, 2
	cmp	si, RIND	;sees if end of array has been reached
	ja	skp17		;if it has been reached
	jmp	lp35		;checks next spot
skp17:	ret
CHECKR	ENDP
;
BALL	PROC
	mov	bx, BALLY	;top left y coordinate
	mov	cx, BALLX	;top left x coordinate
lp11:	mov	dl, 036h	;gets the backround color
	push	bx		;pushes register onto stack to save information
	push	cx
	call	PBALL		;prints over last placement of ball
	pop	cx		;gets back information from stack
	pop	bx
;
	add	bx, DelY	;next placement of ball
	cmp	bx, 5		;sees if at top border
	jbe	ngy
	cmp	bx, 192		;sees if at bottom border
	jb	next1
ngy:	call	NEGY1		;deals with it being at top or bottom
;
next1:	add	cx, DelX
	cmp	cx, 5		;sees if at left border
	jbe	ngx
	cmp	cx, 312		;sees if at right border
	jb	next2
ngx:	call	NEGX1		;deals with it being at left or right
;
next2:	mov	dl, 02Ah	;color of ball
	push	bx		;pushes register onto stack to save information
	push	cx
	call	PBALL		;prints ball
	mov	bl, 4		;sets delay as 0.04 seconds
	call	PAUSE1		;calls the delay
	pop	cx		;gets back information from stack
	pop	bx
	call	OCHECK		;checks if ball has hit an obstacle
	mov	ah, 1		;sees if key was presssed
	int	16h
	jnz	stp		;if pressed, go to end
	cmp	DelX, 1
	jb	stp
	cmp	DelY, 1
	ja	lp11
stp:	ret
BALL	ENDP
;
;procedure checks to see if ball has hit an obstacle
OCHECK	PROC
	push	bx		;saves registers for next stage
	push	cx
	cmp	bx, 15		;sees if at the top
	jb	chk1		;in case it is, check the top obstacles
	cmp	bx, 182		;sees if it is at the bottom 
	ja	chk2		;check it in case it is
	cmp	cx, 15		;sees if at right 
	jb	chk3		;checks in case
	cmp	cx, 302		;sees if at left
	ja	chk4
	jmp	donec		;done checking
chk1:	call	CHECKT
	jmp	donec
chk2:	call	CHECKB
	jmp	donec
chk3:	call	CHECKL
	jmp	donec
chk4:	call	CHECKR
	jmp	donec
donec:	pop	cx
	pop	bx
	ret
OCHECK	ENDP
;
;
;this is called if the ball has hit the left or right border.
;When this happens, it negates the change in the x direction with each iteration
NEGX1	PROC
	mov	ax, 1250	;frequency for beep off wall
	mov	dx, 7
	call	NOTE		;beeps when hits wall
	NEG	DelX		;negates delta x
	add	cx, DelX	;counteracts movement outside border
	call	DECX		;decreases momentum in accordance with how the game works
	call	DECY
	inc	SCORE
	ret
NEGX1	ENDP
;
;this is called if the ball has hit the top or bottom border.
;When this happens, it negates the change in the y direction with each iteration
NEGY1	PROC
	mov	ax, 1250	;frequency for beep off wall
	mov	dx, 7
	call	NOTE		;beeps when hits wall
	NEG	DelY		;negates delta y if at top or bottm
	add	bx, DelY	;counteracts movement outside screen
	call	DECY		;decreases momentum in accordance with how the game works
	call	DECX
	inc	SCORE
	ret
NEGY1	ENDP
;
;This procedure slows down the ball by decreasing distance that it travels with each iteration
;	It checks to see if the change in X is positive or negative and does whatever is necessary.
;
DECX	PROC
	cmp	DelX, 128
	ja	other1
	dec	DelX
	jmp	back1
other1:	inc	DelX
back1:	ret
DECX	ENDP
;
;This procedure slows down the ball by decreasing distance that it travels with each iteration. 
;	It checks to see if the change in Y is positive or negative and does whatever is necessary.
;
DECY	PROC
	cmp	DelY, 128
	ja	other2
	dec	DelY
	jmp	back2
other2:	inc	DelY
back2:	ret
DECY	ENDP
;
;prints the ball
;
PBALL	PROC
	mov     di, 0a000h	;put the video segment into di
        mov     es, di		;so it can be easily put into ds
        xor     di, di		;start writing at coordinates (0,0)
	mov	ax, 320		;sets up ax to get coordinate
	push	dx		;saves dx register
	mul	bx	
	mov	di, ax		;
	add	di, cx		;
	mov	cl, 0		;x offset in dl register
	mov	bl, 0		;y offset in bl register	
	pop	dx		;gets dx register back from stack
	mov	al, dl		;
lp10:	stosb
	inc	cl		;increments current value of x
	cmp	cl, 3		;sees if end of line has been reached
	jb	lp10
	add	di, 320		;progresses Y value
	sub	di, 3		;goes to beginning of x
	mov	cl, 0
	inc	bl
	cmp	bl, 3		;sees if end reached
	jb	lp10
	ret	
PBALL	ENDP
;
;This paints the top of the bar that shows the speed and accuracy
;
BAR	PROC
	;top of bar
	mov	COLOR, 090h	;sets color of green
	mov	XMIN, 80	;the minimum x value. the right value
	mov	XLEN, 160	;length of bar
	mov	YMIN, 145	;place of bar in y-axis
	call	LINEH
;
	;bottom of bar
	mov	COLOR, 090h	;sets color of green
	mov	XMIN, 80	;the minimum x value. the right value
	mov	XLEN, 160	;length of bar
	mov	YMIN, 155	;place of bar in y-axis
	call	LINEH	
;
	;left line of bar
	mov	COLOR, 090h	;sets color of green
	mov	XMIN, 80	;the minimum x value. the right value
	mov	YMIN, 145	;place of bar in y-axis
	mov	YLEN, 10	;place of bar in y-axis
	call	LINEV	
;
	;right line of bar
	mov	COLOR, 090h	;sets color of green
	mov	XMIN, 240	;the minimum x value. the right value
	mov	YMIN, 145	;place of bar in y-axis
	mov	YLEN, 10	;place of bar in y-axis
	call	LINEV
	ret
BAR	ENDP
;
;this fills in the bar. it draws the bar by drawing vertical lines to make the rectangle
;
FILLB	PROC
	mov     di, 0a000h	;put the video segment into di
        mov     es, di		;so it can be easily put into ds
        xor     di, di		;start writing at coordinates (0,0)
	mov	bx, 0		;bx is used later to keep track of x-value
	mov	cx, 0		;cx is used to keep track of Y-value	
lp9:	mov	dx, 146		;y coordinate of top
	mov	ax, 320		;sets up ax to get coordinate
	mul	dx
	mov	di, ax		;
	add	di, 81		;x coordinate of left
	add	di, bx		;sees how much x is offset by
lp8:	mov	al, 090h	;the color
	stosb			;writes the pixel
	dec	di		;counteracts the increment done by previous command
	add	di, 320		;goes to next y-value
	inc	cx		;increments register computing the y offset
	cmp	cx, 8		;if end of line reached
	jbe	lp8		;loops to get vertical pixel
;calls the delay
	push	bx		;saves the registers for when the delay is called
	push	di
	mov	bl, 1		;sets delay for each iteration, so it gets animated
	call	PAUSE1
	pop	di		;puts the registers back
	pop	bx
;
	mov	ah, 1		;checks to see if pressed
	int	16h		
	jnz	push1		;returns once pushed
;
	mov	cx, 0		;resets the cx value		
	inc	bx		;increments current offset of x
	cmp	bx, 158		;sees if end of line has been reached
	jbe	lp9		;goes back if not yet
	call	EMPTYB
;
;for both bars, sets speed once user has set it
;
push1:	shr	bx, 1		;divides it by 8
	shr	bx, 1		;divides it by 8
	shr	bx, 1		;divides it by 8
	shr	bx, 1
	add	bx, 6		;gives it some initial speed
	mov	DelX, bx	;sets it as the speed
	mov	DelY, bx
	mov	ax, 250		;plays note when user has decided speed
	mov	dx, 7
	call	NOTE
	ret
FILLB	ENDP
;
;this shows the bar being depleted. it draws the bar by drawing vertical lines to make the rectangle
;
EMPTYB	PROC
	mov     di, 0a000h	;put the video segment into di
        mov     es, di		;so it can be easily put into ds
        xor     di, di		;start writing at coordinates (0,0)
	mov	bx, 0		;bx is used later to keep track of x-value
	mov	cx, 0		;cx is used to keep track of Y-value	
lp3:	mov	dx, 146		;y coordinate of top
	mov	ax, 320		;sets up ax to get coordinate
	mul	dx
	mov	di, ax		;
	add	di, 239		;x coordinate of left
	sub	di, bx		;sees how much x is offset by
lp0:	mov	al, 036h	;the color
	stosb			;writes the pixel
	dec	di		;counteracts the increment done by previous command
	add	di, 320		;goes to next y-value
	inc	cx		;increments register computing the y offset
	cmp	cx, 8		;if end of line reached
	jbe	lp0		;loops to get vertical pixel
;calls the delay
	push	bx		;saves the registers for when the delay is called
	push	di
	mov	bl, 1		;sets delay for each iteration, so it gets animated	
	call	PAUSE1
	pop	di		;puts the registers back
	pop	bx
;
	mov	ah, 1		;checks to see if pressed
	int	16h		
	jnz	push2		;returns once pushed
;
	mov	cx, 0		;resets the cx value		
	inc	bx		;increments current offset of x
	cmp	bx, 158		;sees if end of line has been reached
	jbe	lp3		;goes back if not yet
push2:	neg	bx		;does bx gets 158-bx for use as the speed
	add	bx, 158
	ret
EMPTYB	ENDP
;
;this is used to paint the inner rectangle, playing area
;
INNER	PROC			
	mov	COLOR, 036h	;sets color as light blue
	mov	XMIN, 5		;puts the specs for the playing area into the 
	mov	XLEN, 310	;	parameters for drawing a rectangle.
	mov	YMIN, 5		;
	mov	YLEN, 190	;
	call	RECT
	ret
INNER	ENDP
;
LINEH	PROC			;prints a horizontal line that goes from X to XMAX and sits at Y
	mov     di, 0a000h	;put the video segment into di
        mov     es, di		;so it can be easily put into ds
        xor     di, di		;start writing at coordinates (0,0)
	mov	ax, 320
	mul	YMIN		;puts Y value into ax
	mov	di, ax		;sets pixel index of (0,y)
	add	di, XMIN	;sets index now of (x,y)
	mov	al, COLOR	;sets color of line
	mov	bx, 0		;keeps track of # of pixels printed
	mov	dx, XLEN	;total number of pixels to be printed
lp4:	stosb			;writes the pixel to the screen.
				;	also increments di so that it will go to the 
				;	next spot in the horizontal line when called
	inc	bx		;
	cmp	bx, dx		;sees if total number of pixels to be written has been
	jb	lp4
	ret	
LINEH	ENDP
;
RECT	PROC
	mov     di, 0a000h	;put the video segment into di
        mov     es, di		;so it can be easily put into ds
        xor     di, di		;start writing at coordinates (0,0)
	mov	ax, 320		;sets up ax to get coordinate
	mul	YMIN	
	mov	bx, 0		;restores x value. bx is used later to keep track of x-value
	mov	cx, 0		;cx is used to keep track of Y-value	
	mov	di, ax		;
	add	di, XMIN	;
	mov	al, COLOR	;
	mov	dx, XLEN	;moves length into dx register
	mov	si, YLEN
lp1:	stosb
	inc	bx		;increments current value of x
	cmp	bx, dx		;sees if end of line has been reached
	jb	lp1
	add	di, 320		;progresses Y value
	sub	di, bx		;goes to beginning of x
	mov	bx, 0
	inc	cx
	cmp	cx, si		;sees if end reached
	jb	lp1
	ret
RECT	ENDP	
;
LINEv	PROC			;draws a vertical line that goes from Y to YMAX and sits at X
	mov     di, 0a000h	;put the video segment into di
        mov     es, di		;so it can be easily put into ds
        xor     di, di		;start writing at coordinates (0,0)
	mov	ax, 320
	mul	YMIN
	mov	di, ax		;sets pixel index. it's at (0,y) now
	add	di, XMIN	;puts pixel index at x-coordinate
	mov	al, COLOR	
	mov	bx, 0		;keeps track of y coordinate
	mov	dx, YLEN
lp5:	stosb
	dec	di		;counteracts the automatic increment
	add	di, 320		;pixel index at next y-coordinate
	inc	bx
	cmp	bx, dx		;sees if whole line has been drawn
	jbe	lp5		;if not reached, repeats
	ret	
LINEv	ENDP
;
;
;DELAY method borrowed from Dewar Game Program
;BL is set to be the the delay in centi-seconds
;
PAUSE1  PROC
      	PUSH  	AX             ; save registers
      	PUSH  	DX
	mov	dh, 0
      	SUB   	AX,AX          ; zero frequency for rest
      	MOV   	Dl,bl           ; delay of 0.06 secs is reasonable
      	CALL  	NOTE           ; execute delay
      	POP   	DX             ; restore registers
      	POP   	AX
      	RET	                  ; return to caller
PAUSE1  ENDP
;
;The following is the note program from the Dewar game
;
;  Definitions for timer gate control
;
CTRL    EQU   	61H           ; timer gate control port
TIMR    EQU   	00000001B     ; bit to turn timer on
SPKR    EQU   	00000010B     ; bit to turn speaker on
;
;  Definitions of input/output ports to access timer chip
;
TCTL    EQU   	043H          ; port for timer control
TCTR    EQU   	042H          ; port for timer count values
;
;  Definitions of timer control values (to send to control port)
;
TSQW    EQU	10110110B     ; timer 2, 2 bytes, sq wave, binary
LATCH   EQU   	10000000B     ; latch timer 2
;
;  Define 32 bit value used to set timer frequency
;
FRHI    EQU   	0012H          ; timer frequency high (1193180 / 256)
FRLO    EQU   	34DCH          ; timer low (1193180 mod 256)
;
NOTE    PROC
      	PUSH  	AX          ; save registers
      	PUSH  	BX
      	PUSH  	CX
      	PUSH  	DX
      	PUSH  	SI
      	MOV   	BX,AX          ; save frequency in BX
      	MOV   	CX,DX          ; save duration in CX
;
;  We handle the rest (silence) case by using an arbitrary frequency to
;  program the clock so that the normal approach for getting the right
;  delay functions, but we will leave the speaker off in this case.
;
      	MOV   	SI,BX          ; copy frequency to BX
      	OR    	BX,BX          ; test zero frequency (rest)
      	JNZ   	NOT1           ; jump if not
      	MOV   	BX,256         ; else reset to arbitrary non-zero
;
;  Initialize timer and set desired frequency
;
NOT1: 	MOV   	AL,TSQW          ; set timer 2 in square wave mode
      	OUT   	TCTL,AL
      	MOV   	DX,FRHI          ; set DX:AX = 1193180 decimal
      	MOV   	AX,FRLO          ;      = clock frequency
      	DIV   	BX               ; divide by desired frequency
      	OUT   	TCTR,AL          ; output low order of divisor
      	MOV   	AL,AH            ; output high order of divisor
      	OUT   	TCTR,AL
;
;  Turn the timer on, and also the speaker (unless frequency 0 = rest)
;
      	IN    	AL,CTRL          ; read current contents of control port
      	OR    	AL,TIMR          ; turn timer on
      	OR    	SI,SI            ; test zero frequency
      	JZ    	NOT2             ; skip if so (leave speaker off)
      	OR    	AL,SPKR          ; else turn speaker on as well
;
;  Compute number of clock cycles required at this frequency
;
NOT2: 	OUT   	CTRL,AL          ; rewrite control port
      	XCHG  	AX,BX            ; frequency to AX
      	MUL   	CX               ; frequency times secs/100 to DX:AX
      	MOV   	CX,100           ; divide by 100 to get number of beats
      	DIV   	CX
      	SHL   	AX,1             ; times 2 because two clocks/beat
      	XCHG  	AX,CX            ; count of clock cycles to CX
;
;  Loop through clock cycles
;
NOT3:   CALL  	RCTR          ; read initial count
;
;  Loop to wait for clock count to get reset. The count goes from the
;  value we set down to 0, and then is reset back to the set value
;
NOT4: 	MOV   	DX,AX          ; save previous count in DX
      	CALL  	RCTR           ; read count again
      	CMP   	AX,DX          ; compare new count : old count
      	JB    	NOT4           ; loop if new count is lower
      	LOOP  	NOT3           ; else reset, count down cycles
;
;  Wait is complete, so turn off clock and return
;
      	IN    	AL,CTRL           ; read current contents of port
      	AND   	AL,0FFH-TIMR-SPKR ; reset timer/speaker control bits
; note that the above statement is an equation
      	OUT   	CTRL,AL           ; rewrite control port
      	POP   	SI                ; restore registers
      	POP   	DX
      	POP   	CX
      	POP   	BX
      	POP   	AX
      	RET               ; return to caller
NOTE    ENDP

RCTR    PROC
      	MOV   	AL,LATCH         ; latch the counter
      	OUT   	TCTL,AL          ; latch counter
      	IN    	AL,TCTR          ; read lsb of count
      	MOV   	AH,AL
      	IN    	AL,TCTR          ; read msb of count
      	XCHG  	AH,AL            ; count is in AX
      	RET                    ; return to caller
RCTR    ENDP

	end
