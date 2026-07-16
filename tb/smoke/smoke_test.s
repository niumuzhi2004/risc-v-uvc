addi  x3, x0, 0x100
addi  x1, x0, 4
lui   x2, 0xFFFFF
srl   x2, x2, x1
bgeu  x2, x3, -4
sw    x2, 4(x1)
lh    x4, 4(x1)
xor   x9, x4, x0
jal   x5, 8
and   x2, x1, x0 // gets skipped
slt   x6, x1, x5
auipc x7, 0x00001
jalr  x8, x5, 16
// all zero instruction to raise halt flag and terminate simulation