#!/usr/bin/bash

# Function to handle cleanup
cleanup() {
    echo "Stopping alert function..."
    kill "$alert_pid" 
    exit
}

# 1. Process Information:
Proccesses_Info() {
    ps -e -o pid -o ppid -o cmd=name -o pcpu=CPU -o pmem=memory
}

# 2. Kill a Process:
Process_KILL() {
    log_file="process_monitor.log"
    echo 'Enter the PID:'
    read Var_PID
    kill "${Var_PID}"
    if (( $? == 0 )); then
        echo "Process ${Var_PID} killed" >>$log_file
    else
        echo "Process ${Var_PID} not killed">>$log_file  
    fi  
}

# 3. Process Statistics:
Process_statics() {
    ps -e -o pid -o ppid -o pcpu=CPU -o pmem=memory > data.txt
    n_Process=$(ps -e -o pid | wc -l)
    ps -e -o pmem=memory -o pcpu=CPU > data.txt

    file="data.txt"
    column1=1
    column2=2
    sed -i '1d' data.txt
    read sum1 sum2 <<< $(awk -v col1=$column1 -v col2=$column2 '{sum1 += $col1; sum2 += $col2} END {print sum1, sum2}' $file)
    rm -f $file
    echo "The number of processes: ${n_Process} Memory usage (all portions): ${sum1} CPU usage (all portions): ${sum2}"
}

# 4. Real-time Monitoring:
Real_time_data_mointring() {
    while true; do
        Proccesses_Info
        sleep 0.5
        clear
    done
}

# 5. Search and Filter:
Specif_Process() {
    echo 'Do you need to search by name, PID, or User_id?'
    read Search_with
    case "${Search_with}" in
        name)
            echo 'Enter the name:'
            read P_name
            ps -C "$P_name" -o pid -o ppid -o cmd=name -o pcpu=CPU -o pmem=memory
            ;;
        PID)
            echo 'Enter the PID:'
            read P_PID
            ps -p "$P_PID" -o pid -o ppid -o cmd=name -o pcpu=CPU -o pmem=memory
            ;;
        User_id)
            echo 'Enter User_id:'
            read P_User_id
            ps -U "$P_User_id"
            ;;
        *)
            echo 'Invalid choice!'
            ;;
    esac
}

# 6. Interactive Mode:
Interactive_Mode() {
    echo 'Enter the number to choose an operation:'
    echo "Process Monitor Menu:"
    echo "1. List Running Processes"
    echo "2. Kill a Process"
    echo "3. Show System Process Statistics"
    echo "4. Real-time Monitoring"
    echo "5. Search Processes"
    read operation_var
    case "$operation_var" in
        1)
            Proccesses_Info
            ;;
        2)
            Process_KILL
            ;;
        3)
            Process_statics
            ;;
        4)
            Real_time_data_mointring
            ;;
        5)
            Specif_Process
            ;;
        *)
            echo 'Invalid input!'
            ;;
    esac
}

# 7. Alert Function:
Alert_funciton() {
    # Load configuration file
    CONFIG_FILE="process_monitor.conf"

    if [[ -f $CONFIG_FILE ]]; then
        source $CONFIG_FILE
    else
        echo "Configuration file not found!"
        exit 1
    fi

    while true; do
        ps -e -o pmem=memory -o pcpu=CPU > data.txt
        file="data.txt"
        column1=1
        column2=2
        # delte first line
        sed -i '1d' data.txt
        # store two variable for CPU and MEM usage
        read sum1 sum2 <<< $(awk -v col1=$column1 -v col2=$column2 '{sum1 += $col1; sum2 += $col2} END {print sum1, sum2}' $file)
        rm -f $file

        if (( $(echo "${sum2} > ${CPU_ALERT_THRESHOLD}" | bc -l) )); then
            echo "Alert: CPU usage is more than the selected threshold."
        fi

        if (( $(echo "${sum1} > ${MEMORY_ALERT_THRESHOLD}" | bc -l) )); then
            echo "Alert: Memory usage is more than the selected threshold."
        fi
        sleep "$UPDATE_INTERVAL"
    done
}

# Trap signals to ensure cleanup
trap cleanup SIGINT SIGTERM

# Run Alert_funciton in the background and store its PID
Alert_funciton &
alert_pid=$!

# Run Interactive Mode
while true; do
    Interactive_Mode
done

# Wait for the background process to finish
# to make sure the script not terminate before terminate allert function
wait
