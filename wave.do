onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label Clock /core_tb/core_inst/clock
add wave -noupdate -label Reset /core_tb/core_inst/reset
add wave -noupdate -expand -group Fetch -color Blue -label PC -radix hexadecimal /core_tb/core_inst/fetch_inst/pc
add wave -noupdate -expand -group Fetch -color Blue -label Instruction -radix hexadecimal /core_tb/core_inst/fetch_inst/instr
add wave -noupdate -expand -group Decode -color Red -label Instruction -radix hexadecimal /core_tb/core_inst/decode_inst/instr
add wave -noupdate -expand -group Decode -color Red -label RS -radix unsigned /core_tb/core_inst/decode_inst/rs
add wave -noupdate -expand -group Decode -color Red -label RT -radix unsigned /core_tb/core_inst/decode_inst/rt
add wave -noupdate -expand -group Decode -color Red -label RD_eff -radix unsigned /core_tb/core_inst/decode_inst/address_d
add wave -noupdate -expand -group Decode -color Red -label Reg_File_Data_1 -radix decimal /core_tb/core_inst/decode_inst/reg_file_data_1
add wave -noupdate -expand -group Decode -color Red -label Reg_File_Data_2 -radix decimal /core_tb/core_inst/decode_inst/reg_file_data_2
add wave -noupdate -expand -group Decode -color Red -label Immediate -radix decimal /core_tb/core_inst/decode_inst/immediate
add wave -noupdate -expand -group Execute -color Gray40 -label Input_1 -radix decimal /core_tb/core_inst/execute_inst/ALU_inst/in_s1
add wave -noupdate -expand -group Execute -color Gray40 -label Input_2 -radix decimal /core_tb/core_inst/execute_inst/ALU_inst/in_s2
add wave -noupdate -expand -group Execute -color Gray40 -label Result -radix decimal /core_tb/core_inst/execute_inst/ALU_inst/result
add wave -noupdate -expand -group Execute -color Gray40 -label Hi -radix decimal /core_tb/core_inst/execute_inst/ALU_inst/hi
add wave -noupdate -expand -group Memory -color Gold -label Enable /core_tb/core_inst/mem_stage_inst/enable
add wave -noupdate -expand -group Memory -color Gold -label Read_Write /core_tb/core_inst/mem_stage_inst/read_write
add wave -noupdate -expand -group Memory -color Gold -label Address -radix hexadecimal /core_tb/core_inst/mem_stage_inst/address
add wave -noupdate -expand -group Memory -color Gold -label Data_in -radix decimal /core_tb/core_inst/mem_stage_inst/data_in
add wave -noupdate -expand -group Memory -color Gold -label Data_out -radix decimal /core_tb/core_inst/mem_stage_inst/data_out
add wave -noupdate -expand -group Write_Back -color Magenta -label Write_Back_Data -radix decimal /core_tb/core_inst/write_back_inst/wb_data
add wave -noupdate -expand -label Reg_File -radix decimal /core_tb/core_inst/decode_inst/reg_file_inst/mem
add wave -noupdate -expand -label Mem -radix decimal /core_tb/core_inst/mem_stage_inst/mem_inst/mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {50000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 475
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {6810578 ps} {6825157 ps}
