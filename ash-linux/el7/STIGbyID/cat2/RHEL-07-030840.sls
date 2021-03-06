# STIG ID:	RHEL-07-030840
# Rule ID:	SV-86815r5_rule
# Vuln ID:	V-72191
# SRG ID:	SRG-OS-000471-GPOS-00216
# Finding Level:	medium
#
# Rule Summary:
#	System must audit all uses of the kmod command.
#
# CCI-000172
#    NIST SP 800-53 :: AU-12 c
#    NIST SP 800-53A :: AU-12.1 (iv)
#    NIST SP 800-53 Revision 4 :: AU-12 c
#
#################################################################
{%- set stig_id = 'RHEL-07-030840' %}
{%- set helperLoc = 'ash-linux/el7/STIGbyID/cat2/files' %}
{%- set skipIt = salt.pillar.get('ash-linux:lookup:skip-stigs', []) %}
{%- set ruleFile = '/etc/audit/rules.d/audit.rules' %}
{%- set path2mon = '/bin/kmod' %}
{%- set key2mon = 'module-change' %}

script_{{ stig_id }}-describe:
  cmd.script:
    - source: salt://{{ helperLoc }}/{{ stig_id }}.sh
    - cwd: /root

{%- if stig_id in skipIt %}
notify_{{ stig_id }}-skipSet:
  cmd.run:
    - name: 'printf "\nchanged=no comment=''Handler for {{ stig_id }} has been selected for skip.''\n"'
    - stateful: True
    - cwd: /root
{%- else %}
touch_{{ stig_id }}-{{ ruleFile }}:
  file.touch:
    - name: '{{ ruleFile }}'
    - unless:
      - 'test -e {{ ruleFile }}'

file_{{ stig_id }}-{{ ruleFile }}-bin:
  file.replace:
    - name: '{{ ruleFile }}'
    - pattern: '^-w {{ path2mon }}.*$'
    - repl: '-w {{ path2mon }} -p x -F auid!=4294967295 -k {{ key2mon }}'
    - append_if_not_found: True

file_{{ stig_id }}-{{ ruleFile }}-ubin:
  file.replace:
    - name: '{{ ruleFile }}'
    - pattern: '^-w {{ path2mon }}.*$'
    - repl: '-w /usr{{ path2mon }} -p x -F auid!=4294967295 -k {{ key2mon }}'
    - append_if_not_found: True
{%- endif %}
