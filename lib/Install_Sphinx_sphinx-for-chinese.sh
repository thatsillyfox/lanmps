cd $IN_DOWN
tar -zxvf sphinx-for-chinese-2.2.1-dev-r4311.tar.gz

cd $IN_DOWN/sphinx-for-chinese-2.2.1-dev-r4311
./configure --prefix=$IN_DIR/sphinx-for-chinese \
--with-mysql \
--with-pgsql \
--without-unixodbc \
--enable-id64
make && make install

cd $IN_DOWN
tar -zxvf xdict_1.1.tar.gz
$IN_DIR/sphinx-for-chinese/bin/mkdict xdict_1.1.txt xdict
cp xdict $IN_DIR/sphinx-for-chinese/etc/

file_cp init.d.sphinx-for-chinese $IN_DIR/init.d/sphinx-for-chinese
if [ ! $IN_DIR = "/www/lanmps" ]; then
	sed -i 's:/www/lanmps:'$IN_DIR':g' $IN_DIR/init.d/sphinx-for-chinese
fi

chmod +x $IN_DIR/init.d/sphinx-for-chinese

if [ $ETC_INIT_D_LN = 1 ]; then
	ln -s $IN_DIR/init.d/sphinx-for-chinese /etc/init.d/sphinx-for-chinese
fi