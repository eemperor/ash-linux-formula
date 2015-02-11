{% from "ash-linux/fix_perms/0444_mode.jinja" import mode_0444_files with context %}

{% for filename in mode_0444_files %}
  {% if salt['file.file_exists'](filename) %}
{{ filename }}:
  file.managed:
    - mode: 0444
  {% endif %}
{% endfor %}
