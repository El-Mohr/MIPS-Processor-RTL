#proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib} }

set CUSTOM_DO_FILE  "wave.do"
set run_do_file [file isfile $CUSTOM_DO_FILE]
set LIB_DIR         ./libs
set WORK_DIR        work
set TOP core_tb

vlib         $LIB_DIR
vlib         [subst $LIB_DIR/$WORK_DIR/]
vmap work    [subst $LIB_DIR/$WORK_DIR/]



vlog -work work "./mem.v"
vlog -work work "./fetch.v"
vlog -work work "./core_defines.v"
vlog -work work "./decoder.v"
vlog -work work "./reg_comp.v"
vlog -work work "./reg_file.v"
vlog -work work "./decode.v"
vlog -work work "./ALU.v"
vlog -work work "./execute.v"
vlog -work work "./mem_stage.v"
vlog -work work "./write_back.v"
vlog -work work "./core.v"
vlog -work work "./core_tb.v"

if {$run_do_file == 1} {
	vsim -novopt -t ps -L work $TOP -do $CUSTOM_DO_FILE 
} else {
	vsim -novopt -t ps -L work $TOP 
}

log /* -r

run -all

