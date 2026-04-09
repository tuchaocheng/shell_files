####使用说明
#1.需将爱企查下载的execl文件先转换成sql
#2.将sql文件上传到当前目录下，进行更改名称为source_file.sql,或执行脚本的后面输入对应的sql文件名称
#3.运行方式：bash   脚本名称  爱企查execl-to-sql-file.sql 营业执照名称字数{低于字数不执行,default:5}  省市
#Example:   bash  grep-aqc-sql.sh  aqc-execl-to-sql-file.sql  6  河南省郑州市

######sql_grep
file_sql_name_init="source_file.sql"   ###上传的源文件名称
file_sql_name="${1:-$file_sql_name_init}"   ###上传的源文件名称,此行勿动
tmp_sql_name='tmp.sql'
out_sms_sql_name="out_sms_sql.txt"
my_tel=13236596567    ####发件人电话
##===================================================================
###筛选新疆或西藏选择【默认关闭】
filter_xj_zone=off  #开启请设置为on,关闭请设置off
###筛选指定省份【和下面的筛选省区 二选一 使用,若省和省-区都填,优先使用省-区参数】
filter_province=""
#filter_province="河南省"  #若筛选新疆或西藏，请将上面filter_zone=off
filter_province="${3:-$filter_province}"  #若筛选新疆或西藏，请将上面filter_zone=off
###筛选指定省-区
filter_province_District=""
#filter_province_District="河南省郑州市"   #若只筛选省,请将此处置空 例: filter_province_District=""
filter_province_District="${3:-$filter_province_District}"
##==================================================================
#导出的文件名称
out_txt_name=test_out.txt
rm -rf  $out_txt_name &>/dev/null #先清空已存在的文件
#cat $file_sql_name |grep "VALUES" > $tmp_sql_name
#cat $file_sql_name  |grep "VALUES" | grep "开业" |grep -E '1[3,5-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\b' > $tmp_sql_name 
#此命令获取的是所有包含手机号的店铺名称
cat $file_sql_name  |grep 'VALUES' |grep '开业'  |grep -E '1[3,5-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\b' |awk -F "'" '{print $2}'  > $tmp_sql_name
  #cat  $tmp_sql_name
    ##筛选新疆or西藏,筛选后进行对缓存文件中的店铺名称删除
      if [  $filter_xj_zone == on ];then
         for xinjiang_zone_shop_name in $(cat $tmp_sql_name) ; do
           ###省
           province_xj=$(cat $file_sql_name |grep $xinjiang_zone_shop_name | awk  -F "," '{print $9}' |awk  -F  "'" '{print $2}')
           if [[ $province_xj == "新疆维吾尔自治区"  ||  $province_xj == "西藏自治区" ]];then
             #echo 0000
             echo " $xinjiang_zone_shop_name 所属地为【$province_xj】 已去除掉......"
             #delete xj_zone 删除tmp_sql文件中的新疆和西藏地区的店铺名称
             sed -i   "/$xinjiang_zone_shop_name/d" $tmp_sql_name 
           
           fi
           ##城市
           #city=$(cat $file_sql_name |grep $shop_name | awk  -F "," '{print $10}' |awk  -F  "'" '{print $2}')
         done
      fi
    ##筛选指定省区
            ####筛选指定的省或省区,筛选后通过修改tmp_sql文件内容{省区大于省}
           if [[ ! -z  $filter_province_District  || ! -z $filter_province  ]] ; then
               echo  oooo
               #filter_province_init=$filter_province_District
               filter_province_init_name=${filter_province_District:-$filter_province}
               echo $filter_province_init_name
               #rm -rf filter_province_city_tmp.txt & >/dev/null 
               echo >  filter_province_city_tmp.txt
               for filter_province_init_shop_name in $(cat $tmp_sql_name) ; do
                 ###省
                 province_filter=$(cat $file_sql_name |grep $filter_province_init_shop_name  | awk  -F "," '{print $9}' |awk  -F  "'" '{print $2}')
                 ##城市
                 city_filter=$(cat $file_sql_name |grep $filter_province_init_shop_name | awk  -F "," '{print $10}' |awk  -F  "'" '{print $2}')
                 #echo 99999999999
                 #echo $filter_province_init_name
                 #echo $province_filter$city_filter
                 #echo $province_filter
                 if [[ $filter_province_init_name == $province_filter$city_filter ]];then
                   echo $filter_province_init_shop_name >> filter_province_city_tmp.txt
                   echo " $filter_province_init_shop_name 所属【省区】为【$filter_province_init_name】 已单独筛选处理......"
                 elif [[  $filter_province_init_name == $province_filter ]];then
                   echo $filter_province_init_shop_name >> filter_province_city_tmp.txt
                   echo " $filter_province_init_shop_name 所属【省】为【$filter_province_init_name】 已单独筛选处理......"
                 else
                   echo -e "\033[31m-------------------------------------------------------------------\033[37m" 
                   echo -e "\033[31m$filter_province_init_shop_name非对应省区【$filter_province_init_name】,已忽略......\033[37m"
                   echo -e "\033[31m-------------------------------------------------------------------\033[37m" 
                   
                 
                 fi
               done
               #####填写省区错误检查
                 filter_province_city_check_num=$(cat filter_province_city_tmp.txt| wc -l)
                   if [ $filter_province_city_check_num  -le 1  ];then
                      echo -e "\033[31m-------------------------------------------------------------------\033[37m" 
                      echo -e "\033[31m 脚本停止! 停止原因:无对应省区【$filter_province_init_name】,请检查......\033[37m"
                      echo -e "\033[31m-------------------------------------------------------------------\033[37m" 
                      exit
                   fi
                 /bin/mv  filter_province_city_tmp.txt $tmp_sql_name
           fi


  echo -e "\033[32m-------------------------------开始运行----------------------------------------\033[0m"
  #通过对应店铺名称检索对应的手机号，取第一个或取仅有的一个手机号码
  for shop_name in $(cat $tmp_sql_name) ; do
    #sleep 1 #间断1s,防止数量过多处理异常
    #通过对应店铺名称检索对应的手机号，取所有的手机号码
    tel=$(cat $file_sql_name |grep $shop_name | grep -oE '1[3,5-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\b')
    #通过对应店铺名称检索的所有手机号，取第一个的手机号码
    tel_onlyOne=$(echo $tel|awk '{print $1}' )
    #tel2=$(cat $file_sql_name |grep $shop_name | grep -oE '1[3,5-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\b' |awk 'NR=1')
    #echo $tel2
    #通过对应店铺名称检索对应的法定人姓名
    name=$(cat $file_sql_name |grep $shop_name | awk  -F "'" '{print $6}' )
    #筛选店铺名称低于指定数字(默认5)个字
      shop_name_length_allow=${2:-5}
      #shop_name_length_allow=4
      #健康检查:检查店铺名称是否设置3以下
         echo $shop_name_length_allow | grep -q -E "^[0-9]+$" &>/dev/null
         shop_name_length_out_check=$(echo $?)
         #if [[ $shop_name_length_allow -le  3  ||  $shop_name_length_out_check -gt 0  ]];then
         if [[ $shop_name_length_out_check != 0  ||  $shop_name_length_allow -le  3 ]];then
            echo -e "\033[31m 店铺名称字数【$shop_name_length_allow】设置错误,禁止设置3以下或非数字 \033[37m" 
            echo -e "\033[32m Example 【 bash  grep-aqc-sql.sh(脚本名称)  aqc-execl-to-sql-file.sql(源文件)  6(店铺名称字数)  河南省郑州市(筛选省区,默认不写即为所有省) 】\033[37m" 
            exit 
         fi
      shop_name_length=${#shop_name}
      if [ $shop_name_length -gt $shop_name_length_allow ];then
         ##test name&shop_name,tel_onlyOne
         #echo  "--------------------------------------------------------------------------------"
         #echo  "尊敬的$shop_name - $name,你的手机号为"$tel_onlyOne
         ##取值，通过已填手机号获取店铺名称，并根据店铺名称获取省区
         ##店铺名称
         shop_name=$shop_name
         ###法定人姓名
         name=$name
         ###联系方式电话
         ###所属行业
         industry=$(cat $file_sql_name |grep $shop_name | awk  -F "," '{print $21}' |awk -F "'" '{print $2}' )
         tel=$tel
         ##联系人第一电话
         tel_onlyOne=$tel_onlyOne
         ###省
         province=$(cat $file_sql_name |grep $shop_name | awk  -F "," '{print $9}' |awk  -F  "'" '{print $2}')
         ##城市
         city=$(cat $file_sql_name |grep $shop_name | awk  -F "," '{print $10}' |awk  -F  "'" '{print $2}')
         ##区
         District=$(cat $file_sql_name |grep $shop_name | awk  -F "," '{print $11}' |awk  -F  "'" '{print $2}')
             
         echo -e "\033[32m--------------------------------------------------------------------------------\033[0m"
         echo -e "\033[32m店铺【$shop_name】	姓名【$name】	手机【$tel_onlyOne】行业【$industry】	地址【$province-$city】\033[0m"
  
         ##将相关数据填入txt中，用于手动添加电话和查询
         echo $shop_name	$name	$tel_onlyOne	所属人地址【$province-$city】>> $out_txt_name
         #sms_model
           #DbussmsforwardcPlus
              #sms_context
              # 
              # 
              #
              #
              #
              #
              sms_context="尊敬的 $shop_name【$name先生(女士)】 , 你好！这边是义乌库存贸易，内有廉价文具&百货日用品出售，全部低于市场批发价格，有意可加 $my_tel 细聊，如有打扰请见谅  "
              #echo $sms_context
cat <<EOF
  尊敬的 $shop_name【$name先生(女士)】 , 你好！
这边是义乌库存贸易，内有廉价文具&百货日用品出售，全部低于市场批发价格
有意可加 $my_tel【微信】 细聊，如有打扰请见谅 
EOF
      else
        echo -e "\033[31m ---------------------------------------------------------------------------\033[37m"
        echo -e "\033[31m$shop_name 的长度为$shop_name_length,小于设置的字符数量【$shop_name_length_allow】\033[37m"
        echo -e "\033[31m ---------------------------------------------------------------------------\033[37m"
      fi
  done 
   
  echo -e "\033[31m ---------------------------------------------------------------------------\033[37m"
  echo -e "\033[31m ------已根据要求全部执行,并将执行的相关信息存入$out_txt_name文件中---------\033[37m"
  echo -e "\033[31m ---------------------------------------------------------------------------\033[37m"


#rm -rf $tmp_sql_name
