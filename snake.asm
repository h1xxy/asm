.model tiny
.org 100h  
.data    
    lenght db 4
    snake dw 50,0,50 dup(0)
    tempLenght db 0   
    snakeDir db 0 
    fruit db 0 
    score dw 0  
    tempScore db 0
    msg_score db "Score: ",'$'
    game_overMsg db "GAME  OVER",'$'   
    time dw 50000  
    count db 0
    
.code
start:  
  ;настройка видеобуфера
  mov ah,00h
  mov al,03 
  int 10h                                 
  ;установка активной страницы
  mov ah,05h
  mov al,0                                  
  int 10h   
  
  mov ah, 02h
  mov bh, 0
  mov dh, 0
  mov dl, 0
  int 10h
  
  mov ah, 09h
  mov al, 01
  mov bl, 0ah
  mov cx, 79
  int 10h   
  
  mov ah, 02h
  mov bh, 0
  mov dh, 24
  mov dl, 0
  int 10h
  
  mov ah, 09h
  mov al, 01
  mov bl, 0ah
  mov cx, 79
  int 10h
  
  mov dl, 0         
_wall:   
  mov ah, 02h
  mov bh, 0
  mov dh, count
  int 10h
  
  mov ah, 09h
  mov bh, 0
  mov al, 01
  mov bl, 0ah   
  mov cx, 1
  int 10h
  
  inc count
  cmp count, 25
  jne _wall  

  cmp dl, 79
  je  _continue: 

  mov count, 0
  mov dl, 79
  jmp _wall

_continue:  
  
  ;установка курсора на строку столбец
  ;dh - строка
  ;dl - столбец 
  ;установка координат на середину поля
  ;для змейки
  mov dl,35 
  mov dh,12            
  mov snake[2],dx          ;хвост
  
  add dl,3
  mov snake[0],dx             ;галава
  
  mov tempLenght,3
  mov dx,snake[2] 
  mov ah,02h
  mov bh,0
  int 10h           
  ;вывод начальной змейки
  mov ah,09h
  mov al, '*'
  mov cx,4
  mov bl,0ch
  mov bh,0
  int 10h  
     
  mov snakeDir,4dh 
  
  mov al,4dh
  mov ah,03h
  mov snake[4],ax 
  
  mov si,4
  mov di,4 
  
  loop1:    
 
  jmp setscore
  getscore:
  mov ah,86h
  mov dx,time
  mov cx,2
  int 15h 
  
  cmp fruit,0
  je add_fruit
  snake_snake:
  
  mov ah,01h
  int 16h 
  
  jz check_for_simbol
  
  mov ah,00h
  int 16h  
 
  cmp ah,4dh   ;d
  je right
  cmp ah,4bh   ;a
  je left    
  cmp ah,48h   ;w
  je up
  cmp ah,50h   ;s
  je down      
  
  check_for_simbol:  
  cmp si,50
  jne propysk  
  mov ax,snake[si]
  mov si,4
  mov snake[si],ax
  propysk:
  
  ;установка координа на голову змейки  
  cmp snakeDir,4dh 
  je addright
  cmp snakeDir,4bh 
  je addleft
  cmp snakeDir,48h 
  je addup
  cmp snakeDir,50h 
  je adddown 
         
  to_be_continue:
  mov ah,02h                                 
  mov bh,0
  mov dx,snake[0]
  int 10h  
           
  mov ah,08h
  int 10h
  
  mov ah,'@'
  cmp al,ah
  je add_count_snake  
  mov ah,'*' 
  mov bp,33
  cmp al,ah
  je GAME_OVER  
  
  mov ah, 01
  cmp al,ah
  je  GAME_OVER
  
  
  polzok:      
  mov ah,09h
  mov al,'*'
  mov bx,0ch
  mov cx,1 
  mov bh,0
  int 10h
  
  inc tempLenght 
  
  mov bl, lenght 
  cmp tempLenght,bl
  je creat_space
  
  jmp loop1     
  
  ;становить пробел в конце змейки
  creat_space:  
  mov ah,02h
  mov dx,snake[2]
  int 10h
  
  getx:
  mov ah,09h
  mov al,' '
  mov bl,0h
  mov cx,1                  
  int 10h 
  dec tempLenght 
  
  mov ax,snake[di]
  dec ah
  mov snake[di],ax
  
  cmp al,4dh
  je tail_right
  cmp al,4bh
  je tail_left
  cmp al,48h
  je tail_up
  cmp al,50h
  je tail_down
  ee: 
  mov ax,snake[di]
  cmp ah,0
  jne loop1
  add di,2 
  cmp di,50
  jne loop1
  mov di,4
  jmp loop1 
  tail_right:
  mov ax,snake[2]
  inc al
  mov snake[2],ax  
  cmp al,80
  jne ee
  xor al,al
  mov snake[2],ax
  jmp ee
  tail_left:     
  mov ax,snake[2]
  dec al
  mov snake[2],ax        
  cmp al,0
  jnl ee
  mov al,79
  mov snake[2],ax
  jmp ee
  tail_up:  
  mov ax,snake[2]
  dec ah
  mov snake[2],ax
  cmp ah,0
  jnl ee
  mov ah,24
  mov snake[2],ax
  jmp ee
  tail_down:     
  mov ax,snake[2]
  inc ah
  mov snake[2],ax
  cmp ah,25
  jne ee
  mov ah,0
  mov snake[2],ax
  jmp ee
  
  right_new_line:
  xor dl,dl
  jmp a  
  left_new_line:     
  mov dl,79
  jmp b
  up_new_line:   
  mov dh,24
  jmp c
  down_new_line: 
  xor dh,dh
  jmp d
  
  add_count_snake:
  add lenght,1 
  inc score
  inc tempScore  
  dec fruit  
  cmp tempScore,10
  jne polzok
  mov tempScore,0
  sub time,2500
  jmp polzok  
  
  right:       
  cmp snakeDir,4dh
  je check_for_simbol
  cmp snakeDir,4bh
  je check_for_simbol  
  mov snakeDir,4dh 
  add si,2
  mov al,4dh
  xor ah,ah
  mov snake[si],ax
  jmp check_for_simbol
  
  left:  
  cmp snakeDir,4bh
  je check_for_simbol
  cmp snakeDir,4dh
  je check_for_simbol
  mov snakeDir,4bh 
  add si,2        
  mov al,4bh
  xor ah,ah
  mov snake[si],ax
  jmp check_for_simbol
  
  up:                 
  cmp snakeDir,48h
  je check_for_simbol 
  cmp snakeDir,50h
  je check_for_simbol
  mov snakeDir,48h
  add si,2        
  mov al,48h
  xor ah,ah
  mov snake[si],ax
  jmp check_for_simbol
  
  down:               
  cmp snakeDir,50h
  je check_for_simbol
  cmp snakeDir,48h
  je check_for_simbol
  mov snakeDir,50h 
  add si,2        
  mov al,50h
  xor ah,ah
  mov snake[si],ax
  jmp check_for_simbol
             
  addright:    
  mov dx,snake[0]
  inc dl
  cmp dl,80
  je right_new_line
  a:           
  mov snake[0],dx 
  mov ax,snake[si]
  inc ah
  mov snake[si],ax
  jmp to_be_continue
  addleft:       
  mov dx,snake[0]
  dec dl           
  cmp dl,0
  jl left_new_line 
  b:
  mov snake[0],dx 
  mov ax,snake[si]
  inc ah
  mov snake[si],ax
  jmp to_be_continue
  addup:
  mov dx,snake[0]
  dec dh   
  cmp dh,0
  jl up_new_line
  c:              
  mov snake[0],dx
  mov ax,snake[si]
  inc ah
  mov snake[si],ax
  jmp to_be_continue
  adddown:      
  mov dx,snake[0]
  inc dh 
  cmp dh,25
  je down_new_line
  d:              
  mov snake[0],dx 
  mov ax,snake[si]
  inc ah
  mov snake[si],ax
  jmp to_be_continue  
   
  add_fruit:
  mov ah,00h
  int 1ah
  mov ax,dx
  mov cx,dx 
  mov bx,80
  xor dx,dx
  div bx
  mov ax,cx
  mov cx,dx
  mov bx,25  
  xor dx,dx
  div bx
  mov ch,dl
  mov dx,cx
  
  mov ah,02h
  mov bh,0
  int 10h
  
  mov ah,08h
  int 10h
  
  cmp ah,7
  jne add_fruit
  mov ah,'*'
  cmp al,ah
  je add_fruit 
  
  
  mov ah,09h
  mov al,'@'
  mov bl,0eh
  mov cx,1                  
  int 10h 
  inc fruit
  jmp snake_snake
  
  setscore:
  mov ah,13h
  mov al,0
  mov cx,7
  mov dl,70
  mov dh,1 
  mov bl,3eh
  mov bp,offset msg_score
  int 10h
  mov ax,score
  xor bp,bp
  while:  
  mov bx,10
  xor dx,dx
  div bx
  add dx,'0'
  push dx
  inc bp
  cmp ax,0
  jne while   
  mov dl,77
  mov dh, 1  
  vivod:
  mov ah,02h
  mov bh,0 
  int 10h
  
  inc dl 
  pop ax  
  mov ah,09h
  mov bh,0
  mov bl,3eh
  mov cx,1
  dec bp 
  int 10h
  cmp bp,0
  jne vivod
  jmp getscore
  GAME_OVER:     
    mov ah,05h
    mov al,1
    int 10h
  ;устанавливаем вторую страницу;
  ;где написано GAME_OVER    
    mov ah,86h
    mov dx,50000
    mov cx,1
    int 15h 
    
    mov bx,bp
    mov bh,1 
    kk:
    cmp bl,0fh
    jng ww
    sub bl,5
    jmp kk
    ww:
    mov ah,02h
    mov dl,0
    mov dh,12
    int 10h
    mov ah,09h
    mov al,' '
    mov cx,80
    int 10h
     
    
    mov ah,02h
    mov dx,bp
    mov dh,12
    int 10h   
    dec bp
    mov ah,09h
    mov dx,offset game_overMsg
    int 21h
    cmp bp,0
    jnl GAME_OVER           
    mov bp,70  
    jmp GAME_OVER           
   
end start