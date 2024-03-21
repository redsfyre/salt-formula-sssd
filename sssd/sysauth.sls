{# sssd.authconfig #}

{% if grains.kernel == 'Linux' %}

{## import settings from map.jinja ##}
{% from "sssd/map.jinja" import sssd_settings with context %}

include:
  - sssd

{% if grains.os_family == 'RedHat' %}

{% set authconf_pkg = salt['grains.filter_by']({
  '7': 'authconfig',
  '8': 'authselect',
  '9': 'authselect',
}, grain='osmajorrelease', default='9') %}

sssd-sysauth-req-authconfig:
  pkg.installed:
    - name: {{ authconf_pkg }}

{% if grains.osmajorrelease == '7' %}
authconfig_updateall:
  cmd.run:
    - name: authconfig {{ sssd_settings.authconfig.updateall_args }}
    - unless: test "`authconfig {{ sssd_settings.authconfig.updateall_args }} --test`" = "`authconfig --test`"
    - require:
      - pkg: sssd-sysauth-req-authconfig
{% if sssd_settings.service.manage == True %}
      - service: service-sssd
{% endif %}
{% endif %}

{% if grains.osmajorrelease == '8' %}
authselect_updateall:
  cmd.run:
    - name: authselect {{ sssd_settings.authselect.updateall_args }}
    - unless: test "`authselect test sssd with-mkhomedir`" = "`authselect test sssd`"
    - require:
      - pkg: sssd-sysauth-req-authconfig
{% if sssd_settings.service.manage == True %}
      - service: service-sssd
{% endif %}
{% endif %}

{% if grains.osmajorrelease == '9' %}
authselect_updateall:
  cmd.run:
    - name: authselect {{ sssd_settings.authselect.updateall_args }}
    - unless: test "`authselect test sssd with-mkhomedir`" = "`authselect test sssd`"
    - require:
      - pkg: sssd-sysauth-req-authselect
{% if sssd_settings.service.manage == True %}
      - service: service-sssd
{% endif %}
{% endif %}

{% endif %}

{% endif %} {# grains.kernel == 'Linux' #}

{# EOF #}
