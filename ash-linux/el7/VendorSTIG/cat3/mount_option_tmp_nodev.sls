# Finding ID:	
# Version:	mount_option_tmp_nodev
# SRG ID:	
# Finding Level:	low
#
# Rule Summary:
#       The nodev mount option can be used to prevent device
#       files from being created in /tmp. Legitimate character
#       and block devices should not exist within temporary
#       directories like /tmp. Add the nodev option to the
#       fourth column of /etc/fstab for the line which controls
#       mounting of /tmp.
#
# CCI-xxxxxx CCI-xxxxxx
#    NIST SP 800-53 Revision 4 :: CM-7
#    NIST SP 800-53 Revision 4 :: MP-2
#    CIS RHEL 7 Benchmark 1.1.0 :: 1.1.2
#
#################################################################

{%- set stig_id = 'mount_option_tmp_nodev' %}
{%- set helperLoc = 'ash-linux/el7/VendorSTIG/cat3/files' %}
{%- set targMnt = '/tmp' %}
{%- set mntOpt = 'nodev' %}

script_{{ stig_id }}-describe:
  cmd.script:
    - source: salt://{{ helperLoc }}/{{ stig_id }}.sh
    - cwd: /root

{%- if salt.file.search('/etc/fstab', targMnt) %}
  {%- set fstabMnts = salt.mount.fstab() %}
  {%- set mntDev = fstabMnts[targMnt]['device'] %}
  {%- set mntDump = fstabMnts[targMnt]['dump'] %}
  {%- set mntOpts = fstabMnts[targMnt]['opts'] %}
  {%- set mntPass = fstabMnts[targMnt]['pass'] %}
  {%- set mntFstype = fstabMnts[targMnt]['fstype'] %}

  {%- if mntOpt in mntOpts %}
notify_{{ stig_id }}-{{ targMnt }}:
  cmd.run:
    - name: 'printf "\nchanged=no comment=''Mount-def for {{ targMnt }} already has {{ mntOpt }} mount-option: state ok.''\n"'
    - cwd: /root
    - stateful: True
  {%- else %}
    {% do mntOpts.append(mntOpt) %}

fix_{{ stig_id }}-{{ targMnt }}:
  module.run:
    - name: 'mount.set_fstab'
    - m_name: '{{ targMnt }}'
    - device: '{{ mntDev }}'
    - fstype: '{{ mntFstype }}'
    - opts: '{{ mntOpts|join(",") }}'
    - dump: '{{ mntDump }}'
    - pass_num: '{{ mntPass }}'

  {%- endif %}
{%- else %}
  {%- set mntDev = 'tmpfs' %}
  {%- set mntDump = '0' %}
  {%- set mntOpts = [ 'noauto', mntOpt ] %}
  {%- set mntPass = '0' %}
  {%- set mntFstype = 'tmpfs' %}

fix_{{ stig_id }}-{{ targMnt }}:
  module.run:
    - name: 'mount.set_fstab'
    - m_name: '{{ targMnt }}'
    - device: '{{ mntDev }}'
    - fstype: '{{ mntFstype }}'
    - opts: '{{ mntOpts|join(",") }}'
    - dump: '{{ mntDump }}'
    - pass_num: '{{ mntPass }}'

{%- endif %}
