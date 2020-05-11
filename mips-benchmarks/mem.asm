addi $sp, $sp, -16

lui $s0, 0xFF22
addi $s0, $s0, 0x3344

sw $s0, 0($sp)
lw $s1, 0($sp)
lb $s2, 0($sp)
lb $s3, 1($sp)
lb $s4, 2($sp)
lb $s5, 3($sp)
lbu $s6, 0($sp)
lh $s7, 0($sp)
lh $t8, 2($sp)
lhu $t9, 0($sp)
sb $s2, 4($sp)
sb $s2, 5($sp)
sb $s2, 6($sp)
sb $s2, 7($sp)
sh $s7, 8($sp)
sh $s7, 10($sp)

addi $sp, $sp, 16