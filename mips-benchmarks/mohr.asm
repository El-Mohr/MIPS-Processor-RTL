addi $sp, $sp, -8

lui $t0, 0x0040
ori $t0, $t0, 1000
addi $t1, $zero, 3
sw $t1, 0($t0)
addi $t1, $zero, 4
sw $t1, 4($t0)
addi $t1, $zero, 5
sw $t1, 8($t0)

lw $t1, 0($t0) 
lw $t2, 4($t0) 
lw $t4, 8($t0)
add $t3, $t1,$t2 
sw $t3, 12($t0) 
add $t5, $t1, $t4 
sw $t5, 16($t0)

#addi $s1, $zero, 3
#bne $s1, $zero, L1
#addi $s2, $zero, 1
#addi $s3, $zero, 2
#nop
#nop


#L1:
#addi $ra, $zero, 5
#jal L2
#addi $ra $zero, 7
#nop
#nop

#L2:
#addi $t0, $zero, 9
#nop
#nop



addi $sp, $sp, 8