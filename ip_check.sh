

count_total=$(cat /proc/net/dev |wc -l)
count=$(($count_total  - 2))
search_interface=""
ip_all=

#echo $count
for net_interface in $(seq 1 $count );do
  #echo   $net_interface
  #tail -n $net_interface /proc/net/dev
  init_hang=$((2 + $net_interface))

 # sed -n  ""$init_hang"p" /proc/net/dev
  
     int_traffic=$(sed -n ""$init_hang"p"  /proc/net/dev |awk '{print $2}') 
    if [ $int_traffic != 0 ];then
       interface_name=$(sed -n  ""$init_hang"p" /proc/net/dev |awk '{print $1}'|awk -F ':' '{print $1}') 

      #echo "------第$init_hang"行"----$interface_name-------"
      #delete docker 
         echo $interface_name |grep docker &>/dev/null
         #docker_interface_return=$(echo $?)
         #echo $docker_interface_return 
         if  [ $? != 0 ] ;then
           ##find ip
           #ifconfig $interface_name 
           #ip a s $interface_name 
           ip=$(ip a s $interface_name |grep "inet" | awk  '{print $2}' |awk -F '/' '{print $1}' |grep -E '^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$' )
           if [[ $ip != '127.0.0.1' && $ip != '' ]] ;then
              echo "---------开始判断-$interface_name-是否可以{等待15s}------"
    
              #判断该IP流量是否有变化
              sleep 5 
              int_traffic_new=$(sed -n ""$init_hang"p"  /proc/net/dev |awk '{print $2}') 
                if [[ $int_traffic_new != $int_traffic ]];then   
          
                   echo "当前【$interface_name】【$ip】可用"
                   ip_all="${ip_all} 【$interface_name: ${ip}】"
                else
                   echo "---------开始二次判断-$interface_name-是否可以{等待45s}------"
                   sleep 5
                   if [[ $int_traffic_new != $int_traffic ]];then

                   echo "当前【$interface_name】【$ip】可用"
                   ip_all="${ip_all} 【${ip}】"
                   fi
                fi
           fi 
           #ifconfig eth0
          
         fi
      
    fi
done

              echo "          当前可用ip为 $ip_all"


#cat /proc/net/dev

