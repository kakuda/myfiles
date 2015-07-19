#
# English resource of image plugin $Revision: 1.1 $
#

#
# Image Diary -  Upload images and insert to diary.
#
# image( number, 'altword', thumbnail ) - show a image.
#    number - image ID as 0, 1, 2...
#    altword - alt strings of the img element.
#    thumbnail - image ID of thumbnail (optional)
#
# image_left( number, 'altword', thumbnail ) - show a image with "class=left"
# image_right( number, 'altword', thumbnail ) - show a image with "class=right"
#
# image_link( number, 'desc' ) - make link to a image.
#    number - image ID as 0, 1, 2...
#    desc - description of the image.
#
# options in tdiary.conf:
#  @options['image.dir']
#     Directory of uploading images. Default is './images/'.
#     You have to set parmission to writable by web server.
#  @options['image.url']
#     URL of the image directory. Default is './images/'.
#  @options['image.maxnum']
#     Max of number of images per a day. Default is 1.
#     This option is effective in @secure = true.
#  @options['image.maxsize']
#     Max size of an image. Default is 10000 bytes.
#     This option is effective in @secure = true.
#
def image_error_num( max ); "�C�h��x�̦h�i�K #{max} �i�Ϥ�"; end
def image_error_size( max ); "�C�i�Ϥ��̤j��� #{max} bytes"; end
def image_label_list_caption; '�C�X�ΧR���Ϥ�'; end
def image_label_add_caption; '���[�Ϥ�'; end
def image_label_description; '�Ϥ�������'; end
def image_label_add_plugin; '���[��峹��'; end
def image_label_delete; '�N������Ϥ��R��'; end
def image_label_only_jpeg; '�u���� JPEG �榡'; end
def image_label_add_image; '�W�ǹϤ�'; end
