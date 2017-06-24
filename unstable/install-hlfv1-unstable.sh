ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.hfc-key-store
tar -cv * | docker exec -i composer tar x -C /home/composer/.hfc-key-store

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� 1hNY �=Mo�Hv==��7�� 	�T�n���[I�����hYm�[��n�z(�$ѦH��$�/rrH�=$���\����X�c.�a��S��`��H�ԇ-�v˽�z@���W�^}��W�^U��r�b6-Ӂ!K��u�lj����0b1���9&���6�rQ>e���E���#��B�qe��-�5�j�I�І����X�)ʁv[S��FQ �}�^C����ʚ�#Cnµ~,�Ԛr�5��u�֡���A�L�u�,��f�Y��-�0h�5�4��p{H�|��/K��d>��I���� ��� �UX�[��4*.*T�6k��5@7��\�5�~L��:7�'��Aq�&�����Ql��$0��e����03��E�~�mv4�vwe��6��4�&��x$ܨ)!�r�h�Z�-��2�H�i��F�E��#U@R�lsQ�-e-�Ӈ�ܴtFl����G�^���EiȨ�H��n��Vӱ2)����l�\�P�1�w�y�u-Ĺ"3͏dh�A���]�0a��jՆ�-�;��@��<����9��h/!��6��i�N�F�U���eCQ�d}F�* �D��y��+;e)5ڠr�|X�j���/��>!Ï?Zx�<s�m�zo��|\��� ^C�T�����ȝ���|<.\5�c���<c��ϳ���;�d|�����w�l�f��&��Ӹ-������rn6*�<��P��y.�������T5#R���-[��~�(*��j6
����X�<*�wJI�����h������+r��2��Qg�!�?`#�X�qsޫ��х����q���d�-��ǎi�	b�᯴���#�8�8l�����g.��_��hg +/�7a&̄�^�m��A��9�5�Y��y0���?@ʹ�j�u��f�:.�Z6^{�X�֖]̣k� 	�[nô��*��)�pH�Dԙ0�y'�����"�N�r�4d���֘t��[�H^R��jA�f-` �U�"�]C|cr�8a&$�VC��}�뱰	�8�g�z��^B�ԴW��Ֆ��!�VZ��D�[�B!�۱@����2/Tѩ�����x4�z���5/��}c��Z؏Y���qa	}�b17|pp��O�����
8A������(�Y���A��z��j-�Łې]p��:�m�4�B`�C3ꗛ�O並�����
����*�B�r@������MX�A~�h�}��4���	�-D�-#��th ���a#FKױ%ϣ@�$9S5���A�ܕ�K��=�Ӑ���dB5L���F��`��]��@�E��<Rg�K�}l,����d潴�1�a�L{l��ܓ�@���g�a���͸����o6}F��� ��z�i�]R)�:�ѹ1胘��.���Z��+��]eWli.I�yWM��u��<�P����ԡ�NCS�$��Д��?%|HeCگu2~�Ә���3�@3p����)Z<�DLx�j���ӷSxFD�% U�'/_^"Q�#zU�r4a��3��á#+�jp19�0f�ǝ��l?f��Ą�b�7X�>n#��myG4&�?�7{��]������4�x��gr �����jV�lS�)���m��)h-��9�Qi>�ݥR�������)���L���=�����������2X~�.�|��Y"�r�i�b��I�J�r&�{~vq�2�
� ��2�@J��jb��?ÞK`0���CA݁W�r�K��'�Q�Y�R�\K��J&+�w*Ws=�6�wV O�Ku��a �:+xe�:�ח��	��}��xe!�oހ'c	��<�!x���#D����5�Cj��V�
m|�5������iq�L(�p� �Պ:�~t��|+Z����E��3����jpao�{��f6�Y���B��,���Ʈ�d۽��$���̰�癅���^���7��Vhj]��eÚvz�8ʸϠ?�/F�[��җnOcv��8������W8L8v�~0i���?��q���w.0}���-xR�ǅ!����g.0��+�U�i�5��� ڶi� ����!�lʆ�)��������@(�r��]=���$�M��븰	���K8�B5�)��|���1F4gI����#U�GZs�av��C�@Q�]X�<����ut����\�W�Sh��!�~	���]�U�Y9�\��,���t�q�H�O/�7w�(�̨�s�B�����G�����i�ʞ��2q@�܀ўsAo�N<��F�Ş�Ďb|�	�a��
��:����7_�L/�7�����C�������W���R����0L/�%ILe�pS����������
��<~�{��}趬q3j��X� az�����$����/ ������ߛ�?�+b��@�_� .��qI5O�nB֌,P��o�R~|7+��(����	\��;ӄ���ihVٿjg�n�Td�a:n��rs�5x��:䲏�V��hw�
�'�6�Y�b|��Ҩ�����;1e��~4�m��`$�")�Bu�s0�-�~��`�U���~����+2��k�5�b�V���1A�c��0l��3�b�����V��7c���{�%5p�W,㑊W�ޥax�����'�JلT*�v�GI�HD����ؖR���' T�b�g���bȕSˁ�����p��(!��1�|I:*HR�HL�JR�,�T�)�"%+�� �n�$U�gr������Q8Җ��2|9
;�O0�v>����G�Ү����;��:�����V�HB�W���Z7�X��l���i��Rr����4����6*�]i�,I��lg�j�K�-�ZAغf��|���;�� !,;:�^�U�a��;��[�m�&��3����޷��!�b���[�D�?��.��y�o�#z�g�#���N��u�^8Ӿ�%��P��d7 ��ש��[�T��U֯�������������7 ��ۀW&��,}2�F=�N��[yM��A�Gc��oa��1���os)�$��9��Q� X���u�������ڿ�xtR�i�7���t2.������)�`D�<l�<pq�g��)�;j��\��G���;�:�����G�v��ͥ���~d��-��|����q��V��{�wW��T�|�4
4ڳ'�O�=��4�ꘄ׵����K!&������0���9������[��Z��j�	�ۻ<jj�p�c�0�V�os(x��/���)���qa����V�����zx]3�<0f��V�3���"@`_�r����n���@~�b�$p~N�Q�;�X�V�39*��;�?������_�y/��+|
�e���ne�y�a߆+_R��=>�2���'RƺF���ye�?"�^H�LW�K�{k�wk�z�&�*���&��m;��&��{��c���_6]�������p7���?�,�>p����4�	�?�A�ڟ�q�o.�Ο��n��S�����E�&yo3����w4ٻ��F��@�:v�)C�?��Pz��hu�����"�U��WcqV�P�V9^�E�[�
�
�)J�瘨Z�UWW9r���rњRS����UDB����&cQ��Z����4��O�0$�t&�R����$ŊDB�l&��:N&E5];��X�3���f{�xU`O���ZC`��V�^?m���bJ<Nt�E�sh$����b1-u^��K�,"%�;R2��*r��w�V���_����"�K�es;�F+#t��=�X~�;��Kل�nd���+#[t��p�����̵��K���9�%s�;��q�,{,vs��u�0���p�P)��W�zn7!�WD}��-e;�W��ԱR�{g�As�[m�li��!��M��V�����Q2^5�͜�p�v�����R�R���A���'	T��vs���c;��Nk�[u�'���yhl���c&)�3�wJ,*�b]�R�\��q�ȝVU=]�t^�7��ڼ���F���N��|R�[����Q"�v<�9m���Ύ=ȗϓɚSr'��vL�iٴ�I��%�ph���HBD�[߫gY\��b1��t2����j�DV�8�#%"�b2+����~��@�'��N��Ƶs{��)�1�p������7_�Ȧ��Ze.��r�l��d�+����-���*u�NI�ԫ�閹eo���i�P��q�Oo��6^>����5}U9�Z�̤�ʡ�S*,&�~uuu�9_=;�h;HJ�W�S#�>h�ϙx�}h1�r�1�A_\\��8����H8��mӨok���k��D��˰��0}]�A� { ��?Л�m�t�Û�{
7��n;w���.�]�̧�'��L4���,�x�i>Љ��.�����OBQ�LzS�K"���t9˯��H��;�f"�td�/��2��|V2�Vw���G�mַ[+����cUf�����kr��J�QsIQ,�y���W�8��v"���Q,9��~�%�aWɨ�뙲#��%%��8��۶U�AU��\�l�'�v6�*b =�ؒ#�#��ь�k�Ác��G�a1���m�oU��x�a��ܸ�a������v&��}��M�1���AffsLq}=8�svߵ�Á�忿�vϦ�1I��0l���?��_}J���>{��>�������!�y����)�A����@�QVa��ʰ���cQ��Ekq�g�JMV�BMa�1FY�Q%&��VV� ���������+l��˟��?��׿���O_���YK�zH��C��R~��Ѳtl��Lc�˥�P?��u.[.,=���Ǘ4E%M�1mWk5��li���L	.C���O����,�>�d �
��ԏ�N�����������C��=[s��,���#�y? Ǖ ��:�|��0�K!�_m�����߿����_���/�?OO~CW������>��)�۲a���?�����	�c����Btq��|��y,s������уN9�����&�������I�G؋f=]%26S�S�IX�J�R	�D�� �?p) NJ��)�\|��������0F�k3�S�U��-A�B8���^�'�;[~2ҷ��-Ī�,W��*e!
�B-�)
��j���2W����Z�Uk�1��W����#�������ꀐ��~0p�U��]�5{Ա'eC;���$�q�:{�ɤ�3=�(����L�遅n"E5��p%Q��E���*REQ*J:�!�����࣓��	Āa�	�� 9�=r��CJ�*UI�tWw�<�W@u����������q�����6���f5�������s򖼈h���)��O��x��^�e��V%��b���
+��aòW�i��b�����UˈG�������,�J��<Z�^��/��,��8���8��
?r����Gz�����D��X	�G������;I��x�~8W���@䏺��yl����A8�w�pd��;�L�mN֙˜���ϭ���ۄ{)ޛ�z<bg�ή��-�.��5p�;	n�-�<?DO�������G��wuU�Io�\vc��7F���������W,��}.\�6oI�C/��Ѥ�g�����sB��Y��U���0go{f�.��-L�t��/r5R)l_�ɳ�[N=F��,ɵ]����O�~j���%�Bk��$�Ш�Z-�����a<�k׉g1~��k��G���i!vk\I�qOS<1�G��Y褥�
�N�ܘj�J���+Tee94�+�ҨJ����c����۹9d.>WVH�]�fH��H�}D'�Xu	?]���Z�t���Q>.��rD��y6�u�I^�����-f��^��p+���3��d�4�"�=Y4Ϯ�� ��n:�� �~�š��_�_Lkh��qlx��6#f��h)	�m����l�+��q"q�b�%�q]*?���՟�.{1=��	�G�~
����������G�|>���}��Vx����?�����W���?�����w���w?��|����{��M:�ou�Gu�u`���Ko�t���?~5�����.��k~�cGu۰�0t��rY܄�v�ng�V6�¦���@<k`h��ؑ%P+� l�z�0�n]�����W����?���������_��W?�����������'%�;��N�ea������-Q�?��wNc|����|>���N������uz���\�$��2CӤ��Kdm����q!4�>���q���J݌�-�]f�vZU�);'�e�����JG�z}-M�v�����0j|̥8���'қk1���d����Zsv�jv:z�
[2����#,x�-LQ�cTň*Lq&(�H��H#��[|�|�Q��8�$�H2�o��lg�Z�%��P���.�f���\�@�U�l:5n��%'r�yRnτ��A3�6;h�'gHƆ�^�?%�!!iF@��B�d����k+�@ 3��_f����95��V2��β)R���M��(��S�����$P�M��B2Iα@w�tD��i��&��,�X9 ���:�W	Ӟn��XYO��@*�n�;���T�$C�I�%GDY�5D�[	���S��6�+.8/QR��CEb��O�t����8|��G�Ё����]-�c3��}�(?��G!�n�m,�ԧ/_��(=YU�\UQ|0�l� v�JI,!������B���D^�Q�c��+���<R$6b�U.:ى�VC�)�T1א"�d3Hm� �C�CH
�1���՜\��c:����Ӱc�a)���Qg�t#G�I�wd6�tV��� ,Ҟ�Qu�*�'�RK��&Er�>/AU���|^�OD	�Z5P�PaƜ�&�
�b��b$j�&�3��]d��|�%hrH���Er¥����JM���Q>���!��M��*s�l��m��D���,%Üt�Vf~d�R�By�^)7h��+�"�x�%b�x�Saa���\rJ�����N������>0�e�J� %Q�;�jG4�̊Ơ��Ԅ��mx05�%��A��S�2߁�� ��zk8����?���bOP�f���Q�^\TIyЫm�9�3�
Ka�!�9E%|���#�(m?W	�&\�W2l�/tHx!,��ݬcAa�N�L��*�f�z_l�Qî"x�ҙ��&�˄�O���7)�nZ�ܴ��ip�2�U<�M�x���� 7-�nZ�ܴ��n��%��zxY.�H��7����߃N��=��/��I�^��������l^���3�����_���v½���C8�����nr�S���7N������-��O量~/�'�N^m�K�s�{E%�c)��4F>�����x�}����u���khR�ה&���Ү\�	p��[-Ug���X�<(hT�2�gkR(V��b�7G�a[�p�L]�i�����4f����|�;�)j���i��z0�&׃��+d#Zmj�vXAs���^��w�t)��~E�"@�kx��}U�f?[��&ݑҩ��:q���N�i6\o�f^&��eBɵ�`  <��%�A��X�s
�~_�jB��6�\)㖘���+�q�b7��=���s��	G����Sf�6�_^��Z:Q�#�؁e3"��#aL��ˍ#��Wi	���z���]S��z��^��*V��*�R2CHCS�5�\=�{��	ͩ��Ə��\�b��R3�1�̌V�v�&���p����8��"]d	P+VӪ���_7_�TA.��|��e*MW�J�Sxn*yR�<��E���Cx�^f��I�����k�Ro�^?�|���YΟx���>�\|�o���t�' �i�@�>8���������<H}����߾b*��g���HU�q�ri(=)�."�L���[޳V�y���7��[����r����U�'�N���
�4���*�ڣ�돶B�c_2A��y���J���x�S (*J��$93����@���Dź��]���=g0A=M�F��5|�S*[�Bm�鞊�|���"�s���G�QkNV�q 
"�Ա����"n���(*v�I�M�&�x�#���z!6���)	<Y��!Ɲ99\(m1�����-��k��E�my��S�#��#�=p#s^�90I,v�2VvfY��4��2�B���5E�z�4u@�f�C\�͝Ճ",*,=�� �FEn�݊^�1?@�v���.��|��x���gɽ4^���d ���z趚��M�0��X_ C�c�%������(~�\��Ou�t5̀:�+-�3��`���y1��/��\4c�߀���G�.�K�T����B^m�U���,nB����( ����zD��BDtBk*	�F�dż�8�l�MD��tYRfӡ�Mך����V��5�rWS;�	�[5{[u���uW:����F>�n����0~T�U�4�'��.��>��]��>�~�c�����s�U���}��3����w��{��+!���Q]�`��&���!�2Fo�Z��gw�#�<g�Ù�FT���� t��(O�p�`���c�57ʺ=o���T<f�J�&��V�z���~c���X�3eH:�jͣ�-���c�\�bHe���u$֑���X����h�,V�1֢�t���z�W���]溣q�Њu��(�,Y�ꦇh�kC��l�H�B]�Kg��1R���Aܫ�T�+�*m)l���QS!]�	 ĕ�Cm�V����*�-U3E�t$��H�}���L�4��A�K/�ע�o�^_�쭟t���I�I���D4��UDS����]4=Sǌ���Kr�A8	���J��zx9�{��i��T{ltdwn��J�v ���'߃����k�y}��,�v�~>�s��"�?�����逽s�x��x|�9WM��s<F>��2�*��U�=�\�8_t���zx3��w��=Ǐ�:�T*�������/.�ʹ���	�x41�����$�/������!Msd���~-u����/)�z�q��?��s˟�����z�ĵ�����3��������o��l���?
!���۠g>�eSO3�(
�������0x�����w�����Vs��sO��6��)�G�=����G �<�cYt���A�����������=���at��{���1�/:�%����nh��{��9�c�f����m����Ŏ���M��@}F������p&^��������Q�E��>
w��®W��;a��[⿙��w�c��h���������;���}�Ǯ��������C�M����[�}?�]���|���zI?�	����������ڱ����r�!�������������mН����8�s����g0|������m�U�yс�?����`X�PG^i`3nH[(��g��ן��ot��7��<rr��\���j���3x��nA���z��)�jx��E�i39�ob~��U��2y�IU�t�( FvC)����tG��Gy��(���(|q<��#>7�����s}P�Na���?ꎏ��Ɛ��Rpq� �.�8?�+<���Χ����EM��M����x0�Eh"�FZ�k��&J���kAsr�f�ՠ�\-� -�Z��(�^�Ϟ��o�X���A;����,�#k�������m���G��������3g����b���8�[����t���%��\�q=���X7�6l���%��m����������۠5��&��ӹϳڱ��b���l��⠨��D�I���\���B�@,F �X�Y�Bэެ2'���L^ "���l��Q�c'�S8��ff�р�g�̚ղ(�ί�w#Z��@Q�|�`TqBQQ}k�ֽzk�JΉ��ET=�TF*�����gٷ�Gyh�)Aݶ�mF�l����ܳBߝ7��>�g��VWwh�?-�ӛB��c��域�0��o��I�_���?��H�_`������7B#����Ҕ������������0���0��P��Y��t���tŜ �Y�1��<�'I�S��SQD����D�q����E4As��������S������/,�a�ֽV�hRl��q�s�H4�̯b{�G�k+޺����Þ��(���ba��ڽ2�z�[74�bA�tU�B2�C�MYgnO=i�s!���� ���U�w-��r�"��/8<�)���C��W#���o� �����3���i,����WT4���+��������_�����Fh\�!�+�����f9��5�C�7�C�7��_���k�f�?��������A��W�a�����'�\W`�Q���'_���n�o�%~�۟���[�Yo��٦,~t�u��k��0}-�1m}w۵9]գB�?L[O�}����Z����?�51�������w6���;I����r�ӲB\.�ñ���#ų��ڗjx�e�������(lW�ܬڧ5�]8Zw��5o����)�BqM�����r�_��r����ɱ��Z�k�N�MٳI�ڶb�u'�l6j�ʇ鑅�J$���\���W�Io��W�"Y�ڇnubfeǈ�e0�]a��H\V�c�(������d����f�f<�����9�L*/������+ ����B��j?��P����w����������?��A��H�GC�'p������7��i����=�΀vZ��ڝwg��'cGܮ=Z%m��ns���V��i�r����^R���`�]l�2J��n���������l�M�
ֆnj�$'�4y˓��z����������+�|pal���T�on�h'��(�ɓ��MYm�12���w����{%sQ�r0��R�܍5�j?�|��$yّ���{o�P�Q<�?���������y���翢�i�� ������:`��`�����y��a���������^�����ρ�o��&_�2��MД�������x,�����S̳���M�X�!1�������}1��#���2�����G��8X�kX���?X���?��������}�X�?���D���#��������������_P�!��`c0b����������}���?��O��C�W#|���?5���Ƭ��:����͡��~�(�7���/��������|/���+��_��]�8�:�e�I{�8�����fg�b;z�1��χ^���ښ*�O����t�Z]T�Y��3e;�dEX(������www��������7���r!�f�҉O�g+�c�}�<ܼ��?�S9e)i�6�����mwX�B�/�b?��s��2���P�#�/�q��p!-"]�V�Y�ع8�m��K�~08,.r�ұ��봥Odv�Yӎ1�%�(������2а����?sP�5��o�]���G���]���̫�o������gl��D�(�L�?� ���D��<���dEFh�Y6�E�fY��$J��[�����A������|��'v߻;�Z���뽻�T��Ҭ�d=z�5_�c�+�G��v��&�$�X;u1#�����z26�[ud��:��*ê����l����T��-��cB^,�}Y8��7ݐso� -"A[o�BO��09'N�0��6���ƚ]�̟��M���1��?���������؁���:����@b���Ā���#���@>��?(�a����������� ��?�� ���������@&����߷������?�@������Ā�������F�__ }�7��r���s����[��(��g�o�=��`B�g\h��\�������ᛉ��8?|3����5��Er֭���&�fѿ��|Mg�������?^3�Յ����ǎB8���Դ�Z����Z]��)g�o�����k=������	{;XěQ�У�i�u��?VUe��t��W��3H.Íǆ>UǺ{
i�hvW�V�=�SW�#[tX�9Q������wW�h�k=������-k:�3������[7P�u���wo���V���l��:����j�9��hi�r���?�MN��=W䇳�珮�æ,���Q��v�w\1���״�=��)˵Q�*q�.�ұ��N���y�W�=�9�zRt,�ν@�v������3���n����D|�*�v-׶ܟ������)�tr�.!�
������rQ�k)��%Iv�*7%\ۚ�d�<`��� oҥ�+'K
1�o����H�}�]l�w�E���@\�A�b��������t��I�)/PI��qL�Q�d/�\$R�$<K�L��$�dF�9+R4�'yS)�I���s������_���Ö�M��=����a7���f�iD��LO�q�-��)���Ԡ�-�.��;k�J�Oʨ�ܪ3�%8v�yI?�}������C��J��C9ei�]G��MW����ۻ�NQ������-~��E<�D�ǐ4�M�C�G�Z����Fx����%���+M������ ��8�?���)��M��Eq ����C�2�?�!����sO�?�G�����G��X!�a �9�����eX�k�����y�����te����H���3��t��ן��mo�;�Ĺw:��|��v�]˝�j��gsH��,W-m/g�VӶ�:�y�����ˮ���2�I͍��v�f�����W���6���Cm�2��~(�u�P=�.I �L����_��<�8�0ew���G�ƚ��n˒�Wj.r֍R���&j�7ʂl���;7��s����Fj��`�	;
��2p�=��}���!���?��B���]�a�����L�l?"p�����|��۷����7�.�i}V��a���%����'���"���� ^_��_�.�
I��T���{5�J�g3/V7�8�
r�J�2��]Ycz1͝Ӳ��2����Z�p~"��t`L����]:M�)��s'|���pM��O�5��
j*���6���K^�)~���ɪ��K�v��ȱk"��|5�m��L7B�^Z�_��U��iޟg�<_���v��JM��e�b��Iz�
\�ܴ���.�,�?��B�����}�X�?�!�}���?����_ ������G�wj|���ǰ�b���2�#V�T�r����?���?7���['�|���'���s���Ҫ�3��ڗn2a��.�/�C>ݚ�1^0���ǗǄKenS�j7�x���u�s4�~=�,VK�&e�4���)�B���������_�8��7���r!�f�҉�w��������yV�<s���4#��M֛�g*aM�EW���ɩ����N<����vdr.����[�;�:�ȵ����6[f����ѐ^�˙QΦ��^��"��s"�2�9ٚ�չ�R�r�V�\r�nQjIW�+;�귱����!q��_�����?��Ё���T"Py�Hɱ�@%b*�RΐtD��Dfd&2YL
R|��#���GI� ���s����8��~e�W�^n��.£8,;b���Ki0�8;؍�I��������N��La���{���F��^�N�$w�\��T�:��>Ɓ5��$�H�\�֋�up�KS�Y����1�̒������?������n����$s�/M����$��	��Ax�
����U]liJ�t�����5���7���7��A��f�˳)Ǒy&Ź�	�(	|�朔R���Ibα	ɉ	ñ<C		�pyL�i��4������?�?��+����)�XI�]߈���әl˕G�z|���ao�_����Fթ�o���jm�xLӾ��\���Iƺ�ܣs����w.Cv�f���ˬ��tx���Ί�]o5ڻ���^px�S�s�����Fx{��T%, `K��g��,���X�?���hF�!�W@�A�Q�?M�����и�C�7V4��?������� �ߐ��ߐ������_�����b�q�����p�8���?�~�������f9��M ��0���0��v��Q�L�1߸��}�8�?������: x��}�?��������]���_Q����S�����'�&�����#��4�b���o������?<P���\�)�Y���&@���11�������}q��������� 
���]��`��`���`���`���?�������B�Y��@&����߷������?����A����}�X�?���l�r��������A�w#@�7�C�7����/���q��ʮ�qw���#�����p��z1���p�.�D&M�8�3���\��,�b��8�L���X&a�$�D$.��d3!X���Vo�����gx�Y���M�����}��v�eh�g���书|m�Y��:z�,k.%�c�ں�T��;�"g��g4��灛�\P^��.�"����[���J�S�t��o>d$�TJ-'s~k���Fn��َ�<��'u�=a�,'��j��n6�X����`5�e̓v2�Ù�)�O��}©glv�V�4�`O2k�^9�h����JL�>�[�>�gSt�F9+j�|�qwO���g����t������(����p���;��A�Gg��A�G� ���s����?�Z�@���Ow �?`��������_��t��?�����������# ����������� �ׁ�������z�� ��3��_ ��0���	���
�����q�6�C���Z.K��.�َf�B�@��/�Xf�����V�&�գ�hY�+��@:��$��`/WF^H�����h:�7Ô�r��lb>����xcmژ��/U�x���0�_��'kV���S�;���QS�mk��I,���T�2v�Ka6e5h��8�\��S�e�OZ��>e�Z��湓����k�.�B�����б���������� ��;���hH�C�gũ��b�p8�H<&c���=,Bt�yᡱQaL=<FA�ǯ���?�����@���-�œ�g!�T���G��ϊ����,����v�lur&�ӆ�����x�d&��Cm�����M�FA;1�G����c^o��4���5�g�������8���{
����y���8
�_�������Q����O������Obx��@�F�������>���9D:��!1N"ѐ�q��1PC�����c0�`��d�F4r�w� ������W��?�����ԙ��`�\ώ��6T��l���7%.E8�J�n���m��?vxJ��v�c��#��l���e��%���b��$H�z�C�lF����*1��?��Cn�y��[��Jy�����}������/8�m	m�?h��/ں��������D���V�V��&���ʯ�_nV�̓���ਘ)�NL����r��=�5X����}�,e荘�4V�M�W���=_�sz���J���/�շ&���>��-Un�eM�~R�^��K�ϝu�k���q��ꦟ�_P�7�^h�3/�Z�ʳ��H�sc؆�&��:���,{}��������y�fq��8vٰ�������	q��	U�|K�
�k:�d���T�y��S�6U�ٰ���!* ��	����Jr�3�iB�R��p�
��,Lg�ʕ���(��6�l�Ҩ�d�#�n<ەXs�HGg�j�"�E�]�AR�^�?���j���M ����B�S�?�hm|�A�o����濻C������m������ �������'�������{t���	����>����g����Fb�������~w��W��l�e�r�n����0-���T��9O���,���ƚ�	���j �s%���,�[{'��O��ؕ�/�X�d\� �gT�����\��ˌ���u����z��~�I��*/��YY�.?�N��\���\��X��C�e��2��S]#�C����<��&$`UQ�'b�Al�)/���غ����k	���yF����i�`S���0")��SOIX����3b"����ݞ;�|~������x�o�?��mm��A�o����}����C��_��p�zS��-�����G��oo�ο�C~�����Ar��ŋh�,����4W�em��9}��+m��u�7Z&6�i���ۿ�ث���8p��캁\�:/nY?�;�n�i,0x��H�	c9H&cQfCs��k~�A��R�w�� �9|i��wy��|�ࣵ)�9&Z�f�:�Y��M�K��De����Y�}��1��9�h�_�����w0iB-��#"V9�AvT�c����k?�a�!N��x�Oأ4�Gg�4��X��ꈻ{^�W��U�=���Ǥɦ"�M}o�1?E��)����e��)6_؛���X&P4�K"�����;B��h�����`�M�@�����?������Nޛ�l�z\��*�t��A|���������|�����ޡ����	� m�4�[k���\�##i���<*�Y��9r��j��e��1��Np�؋��Ul�@3��W����������|�x�˃E*%�h��t�1a|*ӊ�I���ҘP�w��a�
��}����C%�k�lyJ��a�"�/S�*��ZB6-���1zJ�D.]���kd�G~�;ML�PXB����'���.B�?��Z� ܻg ��?�����������߃�0��
�����?�A�!ԃ�/
�_x��d��o����({5��4�U���j��nE���ۯ[�!������۟�3����
��\��g�al����x��?�#h[*��q��ַ6*�n�,s�2����'(Ց��X8c�\�����TB'1������a�Ut2��]��ŏ����?ׁu~�J�X�O{3�W	2�6�K���j�D�k]��ŝǻ���gd��*8Ѫ�s8��YB4$I�0��3��Af�p�6���C�=����[AW�h�~���A�M���V �@�����O��`��3tZ�������t�?<�!������;��9X>�G��u�r]�4��l��%A�������hqG��{��
�Ȭ��V�lE^#^��$y���1���;�c��jU��,��=�!YUUJ�Xs��ߝ�}w�7������`ju��2⫧h��l�.+����4.��l�5�>��/�jI��=~�(w�gRJ�˭�Z��0j��OA�����w �E��U��/����& ��� �[����1��#�����7�����Ow �P��P����?��J������Xݾd���ߡ�����?� ��z���]�'�`���@;����z������!��i��m�+�;������;��n�'�����?(
v������W���V ����������kS���p� ��[���������
��`���������������m�?0� ����_/���q��m�{��{���^����ǀ�oo������W���`��*'1�GB��2�������G�����~�4�F�+�{?�޽�	���� �*�<�<!��aZ���Ys�
?.'YV�Q�5-�1\1� 
�Jd��9YN��NDs�"�y�+_f��ɸ��:�Q!���o.EAx޲�z���z�����W_��r���ɬ�I�C�z_.��f�QX�H���2�d��쩮��!�����*��D�3�-"<�]c�#[7�T�t-!4Ϩ<_�<�l�RsF$e�w�I �K���bcFL$V��s�/���B/�� �������_���8D��w��?���������ϭ�s��b&b�c<��1��(/�i��S2萤P/��0��8"A��WkHF(=�����?�c�!���)���I����+�?7&���|�E����W+��(y���ƻ��z"�0m�K��D�5G�P�:��G�2�:��6M)̽�{k�����<�����*T��|�nW�7�渃x��	A{���/���el��|�8�-*����O�+��pT�$���D�j��T�/x�Ї�?J��?p�o	��?_ ʼ=E����?����i��A�G+h��?�� �W ���k������
:��9 �������0����������?�����O+ ��������n�?����_+�T�����������A������������0��6 �@���O����� �ϭ�S�B�:��[������� ��%��<
N�@/������o��/������k��2�V�3g/6�N`���m��(����i�/��I{
��&�Zge��S�W��?��<����������"�nO8iz� �+�)ɇ�ɘ��eAE\�#Re���9�ks����S������"\�K��ř훶�a�K����6B�l��7�α��&vr�J�n5����/%�Jb��k���s�_|i�ի#�_|��zs���z����Ň�yL�����h�MU�Wےr�)Mh����x�����Jf^f�3�& ��;b�m�1������J���*N>���z���v�N�����l������`����#�#����b4b$�P1:�I*�I��F�.r�R�p(N1a��$��_E��Q���a��[���B�!\�Mi0�EeE!�9�;���Ğ��]T��X�h������Ǜi�Q*�t���$q�r�ΡlOH�d����8��grB0� u��`�&�\~��Sc=buҭ������z/����}J���#���?����Gi��?���_;����~��}�ZC�?>����T�>�顪?E�Cq��O�C��?y�ͧ+�o�]X����_�=[�#�U;3�ٞ;;�C�ݙ4"��23Y�cW�U�[/���G����P���lW�]���j��@�(!(��C�g�J�$DY)� >"H,	D(��_|D$���B���v�fz6�%>-����{�֩���s�#��$l���Ȩ�E��p���9Ԕ��� U���<;����#���\�D�|�_9��X�w^މ|d'r�f����*�,��t����� �:JW��Dv��H��8wf�^Du|�����]5|N_h�;�H~�jÞ��0���ȉ,$$@3mE�w�%�������plۦmDz�(h�O�_���7�"��u��H'�y�pN�'X�"
w�'�;��~[�Д�y���p_^O��Sk�ёC-��uud��z{t	Ơ)�+����W�i�^�B�%����������#AY)g�*.��ƴ��P'���C'�:A/�3����i�������F��w��	�ȏ��h<��D��}����r�2��VhwFӀEǴOD�R��t��O(+|���)�{��CY�,��`����N���;5�O�h����_p2���	���w���K��u~��֧��3���K+�x�E8�)���(�hɸ��RHB�ڪ�")K(��SpN(���Q]������
���t��'�0.t����Sh~�7|�?��O��_����}z�<�����P����n�T�	h��
�
	dzb�����
2Xr����_� p�_�A��W�A��p�ӭs��9t��mpq!�t��u�߯�Ɦ�@�{�3Е��Ҫ ��4Y=T�W��^g0�Vd�����߿|�?�����_{�nw�#\�ο
]
c��h<��.����N�S�;�fk��-�c��?�&���Ob���yw �lG.�x��>��OD_���'���_����;���{ot�O5կ��D�}�!���ֹk�]�������H�F�������"�%ںhEi'T4��TX�S����T2�m��N �$�R�D��m4�NhI��*�$���}�����w��̟}������|�O.�~�;_��'�������Ń޺	���	R��7�o]?��\���s�Bx�{�Ao=���߻��88��k�A�j3.�D��1�{����nS9W���	xc?N�2�֜I_�a8�$?�Qʬ��e�0c���Z"RˬE��*��5�'�1��%qNl@��H�ejH֓뭉�Gݦ@�Y��|�)[���֬YG-�Q��s��ʲq���n�<z47~��O�8���}�%M$�!��\6O�%��՜Ke9�7�y~\�g����gt�kt�!I�[��(]29��UT�^���'W��,�	�	��[�4w^�i�^������zB��0�Β�e�F�$H�,�iX��Z 1Z�[�y%��Ӂ�aZjGc�W�L�Z��������"��I��t�I6�6���"N��O�#��y��2�D�8�*:i�,�:<5)���!�v�Rk{ݦ���`����<��҄H�<�^}�!RE�C�☥T�Ae�8&A���X<�d�/(9��t<��x��B~��e��<,��,\`��m	�Ix���4B����ELQ����f�3]!��`P��*��k��L��X%'6�J0�r����l���o�^l�Kd;<��-�{Y �HK���M ��o�LA����-*Ѥ���|\�`�U�����(��i;��c,��?~��2~���i��gi�,��\4��%��b���0�-�d���*岩*���i�CC�._s9Ew�Zr>Qt�_&,�].�I����5�(,��ƃ2-�yf���E�>*NfY#�j���2d0���rW�q5in��F���yZ"��-��T�$:ݨڝ>C�KL'.�6�cĖ;�A��<��+y��c�zU˲XM�y�W=�,G���,�a���4�a�,�M�k�e'#z�t,>��!I��l��2����Ĕ(�Đ���,�k-ɯ�+�;SEwI�x���P{�X᾵ܾ�����Hv�
Zh��;h�3?�1C�9����΁��Ѕ8�8ң�yS����vr��z˥���8æ��M@ezZ8�ȶ��F��|;�%ʃ�������L}�t}D�V4**5H���$=$[l����R
��yî۞%�n�U��$���R��L>���&�=jXOdsLdR�{���X�j5�vz>�7Ҳ3��c�MP��W����J`?���q��F�03&s�\�V�FJR9&���)�������(����
��ժn<6)&F=���3S+;�xM�����&�InO�&�*x���t1��b�{Kѝ��R�נ_
V�ס-�b�y~�����uoz�j�Ʒ�_?����ڂ:\!�dM|��쯔��z�&�����_YN�_�}�
�+���s�#��J"�/
M�'�Q:Vd���z7&Lޏ!��&��Y&�ǐ�`I)�)4�8`��5yq��^��jIm�_M�͊�e���T��j�#����kù+�\1)֪Mc2}���-�k�˿�w"'HbkG5��C�\����/�,X��i�S=;սr"�>>y��w:ܯ�pN��|М71�p�Rsd��T�7�7�����=�26
�f�F�h�M��j��Eɥ)�3�n�,���h����~���M,n�i��iUV�S�t��4��{bbK{�}jbOM�����h�iC���Q�:��lMl���XjN���N�������(��O�ܼBr��f�A#37U.N��5�+�$�N�X�KT��m��z	��\��՛��Z��cS��
�YO�nb	_���j�m�Iǫ��߯	T�4F��Ȧg��Fks�(�:M��5�ro�9�*8<[!�|���ҀI�d�a��"o��1�<��Eކ�EN0��1�,���/�cW���̠砧�.@[�c9�pe��*v���A�~r����a����߽��گ߂�q�ڭC��z��ٜ>�9}bs�ĉ���?�_����3�/�Zk<���@��F�B��#:���r (|���tv'[���t���DW$+Q*֎!�r�g�z,ON�,�(�z�)��yM��j�:�Z�/v��L%=;� �f�Rc.%����MHI�'0�&�#���鎧M9V8�7�C>	?�t�oR#���9a6u�n��0��r��J�� ��Q�6����y�����������Ō�Wl�#��eP�V�XE�&��T�i>�i6q��~���sl��8��m�c�z�U��[�3��D7�óG?�P��Ջͯ^�|��ũ��ā��6��s�����*���go�Ѿ��썐���mV�_��hr�7��bG"�������J�#����f�]�.�'=��l��^"���͹=]�����|����Z7O/p��9���S��|�;;�~$xg�>׏d������l���"Lܕ䞩.S�O�oE���Z`�;�m�=�	�:}
}��_��.�ТoJ�{��p�,r��m�$�gV�ipm���:�<O��mp㴽��g ��[����6��l`��6��l`?������� � 