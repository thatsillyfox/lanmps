cd $IN_DOWN
tar zxvf csft-4.1.tar.gz

cd $IN_DOWN/csft-4.1
cd mmseg-3.2.14
./bootstrap
./configure --prefix=$IN_DIR/mmseg3
make && make install


cd $IN_DOWN/csft-4.1/
sh buildconf.sh
./configure \
--prefix=$IN_DIR/coreseek \
--without-unixodbc \
--with-mmseg \
--with-mmseg-includes=$IN_DIR/mmseg3/include/mmseg/ \
--with-mmseg-libs=$IN_DIR/mmseg3/lib/ \
--with-mysql=$IN_DIR/mariadb/
make && make install

##测试mmseg分词，coreseek搜索（需要预先设置好字符集为zh_CN.UTF-8，确保正确显示中文）
cd $IN_DOWN/csft-4.1/testpack
cat var/test/test.xml    #此时应该正确显示中文
$IN_DIR/mmseg3/bin/mmseg -d $IN_DIR/mmseg3/etc var/test/test.xml
$IN_DIR/coreseek/bin/indexer -c etc/csft.conf --all
$IN_DIR/coreseek/bin/search -c etc/csft.conf 网络搜索

file_cp init.d.sphinx-coreseek $IN_DIR/init.d/sphinx-coreseek
if [ ! $IN_DIR = "/www/lanmps" ]; then
	sed -i 's:/www/lanmps:'$IN_DIR':g' $IN_DIR/init.d/sphinx-coreseek
fi

chmod +x $IN_DIR/init.d/sphinx-coreseek

if [ $ETC_INIT_D_LN = 1 ]; then
	ln -s $IN_DIR/init.d/sphinx-coreseek /etc/init.d/sphinx-coreseek
fi