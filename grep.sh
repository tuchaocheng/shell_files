#/bin/bash




######sql_grep
file_sql_name="source_file.sql"
tmp_sql_name='tmp.sql'
out_sms_sql_name="out_sms_sql.txt"
my_tel=13236596567
#导出的文件名称
rm -rf  $out_txt_name &>/dev/null #先清空已存在的文件
out_txt_name=test_out.txt
#cat $file_sql_name |grep "VALUES" > $tmp_sql_name
#cat $file_sql_name  |grep "VALUES" | grep "开业" |grep -E '1[3,5-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\b' > $tmp_sql_name 
#此命令获取的是所有包含手机号的店铺名称
cat $file_sql_name  |grep 'VALUES' |grep '开业'  |grep -E '1[3,5-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\b' |awk -F "'" '{print $2}'  > $tmp_sql_name
  #cat  $tmp_sql_name
  #通过对应店铺名称检索对应的手机号，取第一个或取仅有的一个手机号码
  for shop_name in $(cat $tmp_sql_name) ; do
    sleep 1 #间断1s,防止数量过多处理异常
    #通过对应店铺名称检索对应的手机号，取所有的手机号码
    tel=$(cat $file_sql_name |grep $shop_name | grep -oE '1[3,5-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\b')
    #通过对应店铺名称检索的所有手机号，取第一个的手机号码
    tel_onlyOne=$(echo $tel|awk '{print $1}' )
    #tel2=$(cat $file_sql_name |grep $shop_name | grep -oE '1[3,5-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\b' |awk 'NR=1')
    #echo $tel2
    #通过对应店铺名称检索对应的法定人姓名
    name=$(cat $file_sql_name |grep $shop_name | awk  -F "'" '{print $6}' )
    #筛选店铺名称低于5(包含)个字
      shop_name_length_allow=5
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


rm -rf $tmp_sql_name
bak_out_sms_sql_name=`date   +'%Y-%d-%H-%M'`-$out_sms_sql_name
#mv $out_sms_sql_name  $bak_out_sms_sql_name 


########3-----------------------------------------------------------------
#####txt_grep
file_txt_name="source_file.txt"
tmp_txt_name='tmp.txt'
out_sms_txt_name="out_sms.txt"
my_tel=13236596567
#通过开业状态并且有存入手机号的方式查询，查询后将店店铺名称存入临时文件中
#bug:若联系方式为：手机号+座机号 则无法筛选出
  cat $file_txt_name |grep "开业"  |grep -E '1[3,5-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\b'|awk -F '开业' '{print $1}' > $tmp_txt_name
  #count=`cat $file_txt_name |grep "开业"  |grep -E '1[3,5-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\b'|awk -F '-' '{print $8}'   | awk   '{ gsub("[^0-9]", ""); print }' |wc -l `
  for shop  in $(cat $tmp_txt_name);do
    tel=$(cat $file_txt_name |grep $shop  |grep -E '1[3,5-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\b'|awk -F '-' '{print $8}'   | awk   '{ gsub("[^0-9]", ""); print }' |head -c 11)
    #获取对应店铺名称,去掉个人店铺字样
    shop_name=`cat $file_txt_name |grep $tel |awk -F "开业" '{print $1}' |awk -F  "（" '{print $1}' `
    #获取检索到的店铺名称获取对应法定人姓名
    name=$(cat $file_txt_name |grep $tel |awk -F '开业' '{print $2}' |awk -F '-' '{print $1}' )
    echo  "--------------------------------------------------------------------------------"
    echo  "尊敬的$shop_name【$name先生(女士)】,你的手机号为"$tel
    #sms_model
      #DbussmsforwardcPlus
      #sms_context
         sms_context="尊敬的 $shop_name 【$name先生(女士)】 , 你好！这边是义乌库存贸易，内有廉价文具&百货日用品出售，全部低于市场批发价格，有意可加 $my_tel 细聊，如有打扰请见谅  "
         echo $sms_context

#发送的短信内容话术
cat<< EOF
  尊敬的 $shop_name【$name先生(女士)】 , 你好！
这边是义乌库存贸易，内有廉价文具&百货日用品出售，全部低于市场批发价格
有意可加 $my_tel【微信】 细聊，如有打扰请见谅
EOF

  done 

rm -rf $tmp_txt_name
bak_out_sms_txt_name=`date   +'%Y-%d-%H-%M'`-$out_sms_txt_name
#mv $out_sms_txt_name  $bak_out_sms_txt_name 




#------------------------------------------------------------------------------









