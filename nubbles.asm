;*********************************************************
;
;NUBBLES
;
;By Fredrik H. aka Fredrik H.
;
;This is some very unoptimized probobly messy code for a
;Nibbles clone. And to make it even worse it's not very
;well commented. But what do I care, I only made this
;instead of studying. (Oh, by the way, I have a test in 
;Electronics tomorrow :) ).
;
;I've modified it today 11th August -97 to show who died
;and not to quit directly (play again?).
;
;
;WARNING: I take no responsability for what this program
;might do so don't blame me if something goes wrong.
;T
;*********************************************************
;If you want to e-mail me to say I'm a genious or tell me
;that you too hate studying then e-mail me at:
;    info@ludd.luth.se
;
;*********************************************************
;Keys: #1:arrows or 5,1,2,3
;      #2:w,a,s,d
;      ESC quits
;
;
;Coming up:
;o Make the snakes fat
;o add lifes and levels
;o Obstacles
;o PC-SPEAKER support (who needs anything else)
;o numbers instead of cubes
;o high res vbe 2.0 modes with backgroundpics
;o better syncing
;o make source better
;o network playing (yeah, right)
;
;
;...am I serious about this or what :)
	DOSSEG          
	.MODEL SMALL
	.STACK
	.386
	LOCALS
pic	segment byte
picscr	db      64000 dup(?)
        ends	
	.DATA

tail1	dw	512 dup(?)	;tail-list
tail2	dw	512 dup(?)	;tail-list
tlptr1	dw	?		;next to remove
tlptr2	dw	?		;next to remove
tlf1	dw	?		;taillength
tlf2	dw	?		;taillength

seed		dw	?
kbofs		dw	?
kbseg		dw	?
nrwhere		dw	?
stepx1		dw	?
stepy1		dw	?
x1		dw	280
y1		dw	?
stepx2		dw	?
stepy2		dw	?
x2		dw	?
y2		dw	?
nronscr		db	?

nr1died		db	'Bozo number 1 has died a horrible death!',10,13,'$'
nr2died		db	'Idiot number 2 is no longer with us!',10,13,'$'
bothdied	db	'Both morons died!',10,13,'$'
playagain	db	'Hit SPACE to play again!',10,13,'Hit ESC to quit!',10,13,'$'
slut    	db      'Better than Quake, huh!!!',10,13,'$'


tllong1		db	00h		;How much to grow?
tllong2		db	00h		;How much to grow?

keycode		db	0


.CODE

.STARTUP
	
	mov	ax,3509h		;Save Keyboardint
	int	21h
	mov	kbofs,bx		
	mov	kbseg,es	

	mov	ax,2509h		;Setup new int
	push	cs
	pop	ds
	mov	dx,offset kbint
	int	21h			;Keyboard done

startover:
	mov	ax,@data		;
	mov	ds,ax

	mov	ax,0FFFFh
	mov	stepx1,ax
	inc	ax
	mov	stepy1,ax
	mov	stepy2,ax
	mov	nronscr,al
	inc	ax
	mov	stepx2,ax
	mov	ax,100
	mov	y1,ax
	mov	y2,ax
	mov	ax,40
	mov	x2,ax
	mov	ax,280
	mov	x1,ax
	mov     ax,13h
        int     10h			;320x200x256

	
	mov	ax,pic			;Virtual seg
	mov	es,ax

	mov	ax,0A000h		;Screen
	mov	fs,ax

	mov	ebp,69069
	mov     ax,40h
        mov     gs,ax
        mov     eax,gs:[6Ch]	
        mov     seed,ax
	
	mov	bx,40h
	mov	ax,07E19h
	mov	dx,07D27h
	mov	cx,42h
	mov	[tlf1],cx
	mov	[tlf2],cx
fill:
	mov	[tail1+bx],ax
	mov	[tail2+bx],dx
	inc	ax
	dec	bx
	dec	dx
	dec	bx
	jnz	fill
	mov	[tlptr1],bx
	mov	[tlptr2],bx
	jmp	firsttime
again:
	mov dx,3DAH
	in al,dx
	test al,8
	jnz again
VRTOVER:	
	in al,dx
	test al,8
	jz VRTOVER

	mov	ax,0C02h
	mov	fs:[si],al		;#1
	mov	fs:[di],ah		;#2

	mov	bx,tlf1
	mov	tail1[bx],si
	mov	bx,tlf2
	mov	tail2[bx],di
	xor	ax,ax

	cmp	tllong1,0
	jz	dg1
	dec	tllong1
	jmp	nexttail
dg1:	mov	si,tlptr1
	mov	bx,[tail1+si]
	mov	fs:[bx],al
	add	tlptr1,2
	and	tlptr1,03FFh
	
nexttail:
	cmp	tllong2,0
	jz	dg2
	dec	tllong2
	jmp	goon
dg2:	mov	di,tlptr2
	mov	bx,[tail2+di]
	mov	fs:[bx],al
	add	tlptr2,2
	and	tlptr2,03FFh
goon:
	add	tlf1,2
	add	tlf2,2
	and	tlf1,03FFh
	and	tlf2,03FFh

firsttime:
	cmp	nronscr,0
	jnz	nrok
	mov     bx,seed        
        imul    bx,bp        
        inc     bx            
        mov     seed,bx 	
	and	bx,0FFFDh
	cmp	bx,320*197
	jb	inrange
	sub	bx,320*197
inrange:
	mov	eax,0F0F0F0Fh
	mov	fs:[bx],eax
	mov	fs:[bx+320],eax
	mov	fs:[bx+640],eax
	mov	fs:[bx+960],eax
	mov	nrwhere,bx
	mov	nronscr,al
nrok:	mov	ax,y1
	add	ax,stepy1
	jns	ynoc1
	mov	ax,199
ynoc1:	cmp	ax,200
	jne	yok1
	xor	ax,ax
yok1:
	mov	y1,ax

	shl	ax,6
	mov	si,ax
	shl	si,2
	add	si,ax

	mov	ax,x1
	add	ax,stepx1
	jns	xnoc1
	mov	ax,319
xnoc1:	cmp	ax,320
	jne	xok1
	xor	ax,ax	
xok1:
	mov	x1,ax
	add	si,ax


	
	mov	ax,y2
	add	ax,stepy2
	jns	ynoc2
	mov	ax,199
ynoc2:	cmp	ax,200
	jne	yok2
	xor	ax,ax
yok2:
	mov	y2,ax

	shl	ax,6
	mov	di,ax
	shl	di,2
	add	di,ax

	mov	ax,x2
	add	ax,stepx2
	jns	xnoc2
	mov	ax,319
xnoc2:	cmp	ax,320
	jne	xok2
	xor	ax,ax	
xok2:
	mov	x2,ax
	add	di,ax

	xor	eax,eax
	cmp	byte ptr fs:[si],15
	jne	nohit1
	mov	bx,nrwhere
	mov	fs:[bx],eax
	mov	fs:[bx+320],eax
	mov	fs:[bx+640],eax
	mov	fs:[bx+960],eax

	mov	nronscr,al
	add	tllong1,020h
nohit1: cmp	byte ptr fs:[di],15
	jne	nohit2
	mov	bx,nrwhere
	mov	fs:[bx],eax
	mov	fs:[bx+320],eax
	mov	fs:[bx+640],eax
	mov	fs:[bx+960],eax

	mov	nronscr,al
	add	tllong2,020h
nohit2:
	cmp	byte ptr fs:[si],0
	mov     dx,offset nr1died
	jne	died

	cmp	byte ptr fs:[di],0
	mov     dx,offset nr2died
	jne	died

	cmp	si,di
	mov     dx,offset bothdied
	je	died

	cmp	keycode,129
	jne	again
	mov	dx,offset slut
died:
	mov     ax,3
        int     10h
        mov     ah,09
        int     21h

	mov	dx,offset playagain
        mov     ah,09
        int     21h
	xor	dx,dx
	mov	keycode,dl
waitkey:	
	cmp	keycode,57
	je	startover
	cmp	keycode,129
	jne	waitkey
slutf:  

	mov	ax,2509h
	push	ds
	mov	cx,kbseg
	mov	dx,kbofs
	mov	ds,cx
	int	21h
	pop	ds

	
	mov	dx,offset slut
        mov     ah,09
        int     21h	
        
	mov	ax,4C00h
	int	21h







KBINT	PROC	FAR
	
	pusha	
	push	ds
	mov	ax,@data
	mov	ds,ax

	
	in	al,60h
	mov	cl,al
	in	al,61h
	or	al,80h
	out	61h,al
	and	al,7Fh
	out	61h,al
	
	cmp	cl,32
	je	R2
	ja	pl1		

	cmp	cl,30
	je	L2
	ja	D2
	cmp	cl,17
	jne	klar

U2:	cmp	stepy2,0		;Up #2
	jne	klar
	mov	ax,0FFFFh
	mov	stepy2,ax
	xor	ax,ax
	mov	stepx2,ax
	jmp	klar

R2:	cmp	stepx2,0		;Right #2
	jne	klar
	mov	ax,01h
	mov	stepx2,ax
	xor	ax,ax
	mov	stepy2,ax
	jmp	klar

L2:	cmp	stepx2,0		;Left #2
	jne	klar
	mov	ax,0FFFFh
	mov	stepx2,ax
	xor	ax,ax
	mov	stepy2,ax
	jmp	klar

D2:	cmp	stepy2,0		;Down #2
	jne	klar
	mov	ax,01h
	mov	stepy2,ax
	xor	ax,ax
	mov	stepx2,ax
	jmp	klar


pl1:	cmp	cl,75
	je	L1
	jb	U1cmp		

	cmp	cl,77
	je	R1
	cmp	cl,80
	jne	klar

D1:	cmp	stepy1,0		;Down #1
	jne	klar
	mov	ax,01h
	mov	stepy1,ax
	xor	ax,ax
	mov	stepx1,ax
	jmp	klar


U1cmp:
	cmp	cl,72
	jne	klar
U1:	cmp	stepy1,0		;Up #1
	jne	klar
	mov	ax,0FFFFh
	mov	stepy1,ax
	xor	ax,ax
	mov	stepx1,ax
	jmp	klar

R1:	cmp	stepx1,0		;Right #1
	jne	klar
	mov	ax,01h
	mov	stepx1,ax
	xor	ax,ax
	mov	stepy1,ax
	jmp	klar

L1:	cmp	stepx1,0		;Left #1
	jne	klar
	mov	ax,0FFFFh
	mov	stepx1,ax
	xor	ax,ax
	mov	stepy1,ax

klar:	mov	keycode,cl

        mov     al,20h
        out     20h,al
	pop	ds
	popa
	iret
KBINT	ENDP
END
