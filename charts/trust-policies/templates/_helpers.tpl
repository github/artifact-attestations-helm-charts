{{/*
Generate subjectRegExp value
*/}}
{{- define "clusterimagepolicy.subjectRegExp" -}}
{{- if .Values.policy.subjectRegExp -}}
subjectRegExp: "{{ .Values.policy.subjectRegExp }}"
{{- else -}}
subjectRegExp: https://github.com/{{ .Values.policy.organization | required "One of policy.organization/policy.subjectRegExp is required" }}/{{ .Values.policy.repository }}/\.github/workflows/.*
{{- end -}}
{{- end -}}
{{- define "clusterimagepolicy.images" -}}
{{- range .Values.policy.images -}}
- glob: "{{ . }}"
{{ end -}}
{{- end -}}
{{- define "clusterimagepolicy.exemptImages" -}}
{{- range .Values.policy.exemptImages -}}
- glob: "{{ . }}"
{{ end -}}
{{- end -}}
