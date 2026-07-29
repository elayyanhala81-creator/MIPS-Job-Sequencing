# Job Sequencing with Deadlines
# Hala Elayyan 1230150
# Bisan Sabri 1230027
# Sec2,Sec3
# H_Input:  C:/Users/Leovo/Desktop/Mips.txt 
# B_Input:  C:/Users/besan/Desktop/jobsforarch.txt
# H_Output: D:/MipsProject/output.txt
# B_Output: C:\Users\besan\Desktop\outjobs.txt
################# Data Segment ###############
.data

welcome:      .asciiz "Job Scheduling Program\n"
prompt_file:  .asciiz "Please enter the file path:)\n"
err_open:     .asciiz "Error: File cannot open.\n"
wrong_input:  .asciiz "Error: Wrong input format.\n"
newline:      .asciiz "\n"
file_text:  .asciiz "\n.....File contents.....\n"

sorted_jobs:      .asciiz "\n.....Sorted Jobs.....\n"
job_word:       .asciiz "Job "
deadline_word:  .asciiz " Deadline: "
profit_word:    .asciiz " Profit: "

filepath:     .space 128
file_buffer:  .space 1024

.align 2
job_numbers:     .space 40

.align 2
job_deadlines:    .space 40

.align 2
job_profits:      .space 40

.align 2
number_of_jobs:    .word 0

# schedule, -1 means empty
job_schedule:     .space 40
biggest_deadline: .word 0
final_profit: .word 0

# text messages
msg_job_schedule: .asciiz "\n.....Selected Job sequence.....\n"
time_slot:     .asciiz "Slot "
job_symbol:    .asciiz ": J"
total_word:    .asciiz "Total profit: "
empty_word:    .asciiz "empty"

# file output
output_filename: .asciiz "D:/MipsProject/output.txt"
msg_saved:       .asciiz "\nResult saved to the output file \n"
output_buffer:   .space 512

.text
.globl main

main:
    # show welcome message
    li   $v0, 4
    la   $a0, welcome
    syscall

    # ask for file path
    li   $v0, 4
    la   $a0, prompt_file
    syscall

    # read file path
    li   $v0, 8
    la   $a0, filepath
    li   $a1, 128
    syscall

    # remove enter from path
    la   $t0, filepath

remove_newline:
    lb   $t1, 0($t0)
    beq  $t1, 10, do_replace
    beqz $t1, open_file
    addi $t0, $t0, 1
    j    remove_newline

do_replace:
    sb   $zero, 0($t0)

open_file:
    # open file
    li   $v0, 13
    la   $a0, filepath
    li   $a1, 0
    li   $a2, 0
    syscall

    bltz $v0, file_error
    move $s0, $v0

    # read file
    li   $v0, 14
    move $a0, $s0
    la   $a1, file_buffer
    li   $a2, 1023
    syscall

    # end file text with zero
    move $t2, $v0
    la   $t3, file_buffer
    add  $t3, $t3, $t2
    sb   $zero, 0($t3)

    # show file text
    li   $v0, 4
    la   $a0, file_text
    syscall

    li   $v0, 4
    la   $a0, file_buffer
    syscall

    # close file
    li   $v0, 16
    move $a0, $s0
    syscall

    # start reading jobs
    la   $t0, file_buffer
    li   $s1, 0

parse_loop:
    lb   $t1, 0($t0)

    beqz $t1, parsing_done
    beq  $t1, 10, skip_char
    beq  $t1, 13, skip_char
    beq  $t1, 32, skip_char

    li   $t2, 'J'
    bne  $t1, $t2, format_error

    addi $t0, $t0, 1

    jal  read_number
    move $s2, $v0

    jal  skip_spaces

    jal  read_number
    move $s3, $v0

    jal  skip_spaces

    jal  read_number
    move $s4, $v0

    sll  $t4, $s1, 2

    la   $t5, job_numbers
    add  $t5, $t5, $t4
    sw   $s2, 0($t5)

    la   $t5, job_deadlines
    add  $t5, $t5, $t4
    sw   $s3, 0($t5)

    la   $t5, job_profits
    add  $t5, $t5, $t4
    sw   $s4, 0($t5)

    addi $s1, $s1, 1
    j    parse_loop

skip_char:
    addi $t0, $t0, 1
    j    parse_loop

parsing_done:
    sw   $s1, number_of_jobs

    # sort jobs by profit
    lw   $s5, number_of_jobs
    li   $t6, 0

outer_loop:
    bge  $t6, $s5, sort_done

    li   $s6, 0

    sub  $t7, $s5, $t6
    addi $t7, $t7, -1

inner_loop:
    bge  $s6, $t7, next_outer

    sll  $t2, $s6, 2
    addi $t3, $s6, 1
    sll  $t3, $t3, 2

    la   $t4, job_profits
    add  $t4, $t4, $t2
    lw   $t0, 0($t4)

    la   $t5, job_profits
    add  $t5, $t5, $t3
    lw   $t1, 0($t5)

    bge  $t0, $t1, no_swap

        # swap profits
    sw   $t1, 0($t4)
    sw   $t0, 0($t5)

        # swap deadlines
    la   $t4, job_deadlines
    add  $t4, $t4, $t2
    lw   $t0, 0($t4)

    la   $t5, job_deadlines
    add  $t5, $t5, $t3
    lw   $t1, 0($t5)

    sw   $t1, 0($t4)
    sw   $t0, 0($t5)

        # swap job numbers
    la   $t4, job_numbers
    add  $t4, $t4, $t2
    lw   $t0, 0($t4)

    la   $t5, job_numbers
    add  $t5, $t5, $t3
    lw   $t1, 0($t5)

    sw   $t1, 0($t4)
    sw   $t0, 0($t5)

no_swap:
    addi $s6, $s6, 1
    j    inner_loop

next_outer:
    addi $t6, $t6, 1
    j    outer_loop

sort_done:
    li   $v0, 4
    la   $a0, sorted_jobs
    syscall

    li   $t6, 0
    lw   $s5, number_of_jobs

print_sorted:
    bge  $t6, $s5, find_biggest_deadline

    sll  $t4, $t6, 2

    li   $v0, 4
    la   $a0, job_word
    syscall

    la   $t5, job_numbers
    add  $t5, $t5, $t4
    lw   $a0, 0($t5)
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, deadline_word
    syscall

    la   $t5, job_deadlines
    add  $t5, $t5, $t4
    lw   $a0, 0($t5)
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, profit_word
    syscall

    la   $t5, job_profits
    add  $t5, $t5, $t4
    lw   $a0, 0($t5)
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, newline
    syscall

    addi $t6, $t6, 1
    j    print_sorted

    # find biggest deadline
find_biggest_deadline:
    lw   $s5, number_of_jobs
    li   $t2, 0
    li   $t3, 0

find_max_loop:
    bge  $t2, $s5, max_found

    sll  $t4, $t2, 2
    la   $t5, job_deadlines
    add  $t5, $t5, $t4
    lw   $t6, 0($t5)

    ble  $t6, $t3, not_bigger
    move $t3, $t6

not_bigger:
    addi $t2, $t2, 1
    j    find_max_loop

max_found:
    sw   $t3, biggest_deadline

    la   $t0, job_schedule
    li   $t2, 0

init_slots:
    bgt  $t2, $t3, job_schedule_done
    li   $t4, -1
    sw   $t4, 0($t0)
    addi $t0, $t0, 4
    addi $t2, $t2, 1
    j    init_slots

    # put jobs in slots
job_schedule_done:
    li   $s3, 0

job_loop:
    bge  $s3, $s5, verify_job_schedule

    sll  $t2, $s3, 2
    la   $t3, job_deadlines
    add  $t3, $t3, $t2
    lw   $s4, 0($t3)

try_slot:
    blez $s4, next_job

    addi $t2, $s4, -1
    sll  $t2, $t2, 2
    la   $t3, job_schedule
    add  $t3, $t3, $t2
    lw   $t1, 0($t3)

    bne  $t1, -1, slot_taken

    sll  $t4, $s3, 2
    la   $t5, job_numbers
    add  $t5, $t5, $t4
    lw   $t4, 0($t5)

    sw   $t4, 0($t3)
    j    next_job

slot_taken:
    addi $s4, $s4, -1
    j    try_slot

next_job:
    addi $s3, $s3, 1
    j    job_loop

    # show selected jobs
verify_job_schedule:
    li   $v0, 4
    la   $a0, msg_job_schedule
    syscall

    li   $t2, 0
    lw   $t3, biggest_deadline

verify_loop:
    bge  $t2, $t3, calc_profit

    li   $v0, 4
    la   $a0, time_slot
    syscall

    addi $a0, $t2, 1
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, job_symbol
    syscall

    sll  $t4, $t2, 2
    la   $t5, job_schedule
    add  $t5, $t5, $t4
    lw   $t0, 0($t5)

    beq  $t0, -1, print_empty

    move $a0, $t0
    li   $v0, 1
    syscall
    j    next_verify

print_empty:
    li   $v0, 4
    la   $a0, empty_word
    syscall

next_verify:
    li   $v0, 4
    la   $a0, newline
    syscall

    addi $t2, $t2, 1
    j    verify_loop

    # calculate total profit
calc_profit:
    li   $t6, 0
    li   $t2, 0
    lw   $t3, biggest_deadline

profit_loop:
    bge  $t2, $t3, print_job_schedule

    sll  $t4, $t2, 2
    la   $t5, job_schedule
    add  $t5, $t5, $t4
    lw   $t0, 0($t5)

    beq  $t0, -1, skip_slot

    li   $t4, 0

find_profit:
    bge  $t4, $s5, skip_slot

    sll  $t7, $t4, 2
    la   $t5, job_numbers
    add  $t5, $t5, $t7
    lw   $t1, 0($t5)

    bne  $t1, $t0, try_next

    la   $t5, job_profits
    add  $t5, $t5, $t7
    lw   $t1, 0($t5)
    add  $t6, $t6, $t1
    j    skip_slot

try_next:
    addi $t4, $t4, 1
    j    find_profit

skip_slot:
    addi $t2, $t2, 1
    j    profit_loop

    # print final result
print_job_schedule:
    sw   $t6, final_profit

    li   $v0, 4
    la   $a0, msg_job_schedule
    syscall

    li   $t2, 0
    lw   $t3, biggest_deadline

print_slot_loop:
    bge  $t2, $t3, print_total

    sll  $t4, $t2, 2
    la   $t5, job_schedule
    add  $t5, $t5, $t4
    lw   $t0, 0($t5)

    beq  $t0, -1, next_slot

    li   $v0, 4
    la   $a0, time_slot
    syscall

    addi $a0, $t2, 1
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, job_symbol
    syscall

    move $a0, $t0
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, newline
    syscall

next_slot:
    addi $t2, $t2, 1
    j    print_slot_loop

print_total:
    li   $v0, 4
    la   $a0, total_word
    syscall

    lw   $a0, final_profit
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, newline
    syscall

    # save result in file
    jal  write_results_file

finish_program:
    li   $v0, 10
    syscall



# save result to file
write_results_file:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    la   $s0, output_buffer       # current place in buffer

    la   $a0, msg_job_schedule
    jal  append_string

    li   $s3, 0                  # slot number
    lw   $s4, biggest_deadline       # max deadline

write_slot_loop:
    bge  $s3, $s4, write_total_line

    sll  $t4, $s3, 2
    la   $t5, job_schedule
    add  $t5, $t5, $t4
    lw   $s5, 0($t5)             # save job number

    beq  $s5, -1, write_next_slot

    la   $a0, time_slot
    jal  append_string

    addi $a0, $s3, 1
    jal  append_int

    la   $a0, job_symbol
    jal  append_string

    move $a0, $s5
    jal  append_int

    la   $a0, newline
    jal  append_string

write_next_slot:
    addi $s3, $s3, 1
    j    write_slot_loop

write_total_line:
    la   $a0, total_word
    jal  append_string

    lw   $a0, final_profit
    jal  append_int

    la   $a0, newline
    jal  append_string

    # get buffer size
    la   $t0, output_buffer
    sub  $s1, $s0, $t0

    # open output file
    li   $v0, 13
    la   $a0, output_filename
    li   $a1, 1
    li   $a2, 0
    syscall

    bltz $v0, write_file_done
    move $s2, $v0

    # write to file
    li   $v0, 15
    move $a0, $s2
    la   $a1, output_buffer
    move $a2, $s1
    syscall

    # close output file
    li   $v0, 16
    move $a0, $s2
    syscall

    li   $v0, 4
    la   $a0, msg_saved
    syscall

write_file_done:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# add text to buffer
append_string:
append_string_loop:
    lb   $t0, 0($a0)
    beqz $t0, append_string_done

    sb   $t0, 0($s0)

    addi $a0, $a0, 1
    addi $s0, $s0, 1
    j    append_string_loop

append_string_done:
    jr   $ra


# add number to buffer
append_int:
    bne  $a0, $zero, append_int_nonzero

    li   $t0, '0'
    sb   $t0, 0($s0)
    addi $s0, $s0, 1
    jr   $ra

append_int_nonzero:
    move $t0, $a0              # number
    li   $t1, 0                # count digits

append_digit_loop:
    beqz $t0, write_digits_back

    li   $t2, 10
    div  $t0, $t2
    mfhi $t3                   # extra digit
    mflo $t0                   # new number

    addi $t3, $t3, 48          # make digit text
    addi $sp, $sp, -4
    sw   $t3, 0($sp)
    addi $t1, $t1, 1

    j    append_digit_loop

write_digits_back:
    beqz $t1, append_int_done

    lw   $t3, 0($sp)
    addi $sp, $sp, 4

    sb   $t3, 0($s0)
    addi $s0, $s0, 1
    addi $t1, $t1, -1

    j    write_digits_back

append_int_done:
    jr   $ra


# read number
read_number:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    li   $v0, 0

read_number_loop:
    lb   $t1, 0($t0)

    blt  $t1, '0', read_number_done
    bgt  $t1, '9', read_number_done

    addi $t1, $t1, -48
    mul  $v0, $v0, 10
    add  $v0, $v0, $t1

    addi $t0, $t0, 1
    j    read_number_loop

read_number_done:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra


# skip spaces
skip_spaces:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

skip_spaces_loop:
    lb   $t1, 0($t0)
    bne  $t1, 32, skip_spaces_done
    addi $t0, $t0, 1
    j    skip_spaces_loop

skip_spaces_done:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra


file_error:
    li   $v0, 4
    la   $a0, err_open
    syscall

    li   $v0, 10
    syscall


format_error:
    li   $v0, 4
    la   $a0, wrong_input
    syscall

    li   $v0, 10
    syscall
    