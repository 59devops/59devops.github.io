if [ $# -eq 0 ];
then
    usage
    exit
fi

usage(){
    echo "请填写提交注释信息！"
}

cd /Users/mac/Downloads/OneDrive - VIP University/Hexo/59devops && git add -A
git commit -m "$1"
git push origin source
