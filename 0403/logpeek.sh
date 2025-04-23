#!/bin/bash

trap 'echo -e "\n❗ Ctrl+C 감지됨. 스크립트를 종료합니다."; exit 130' INT

# --help or -h 옵션 처리
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo -e "📝 logpeek.sh - GPT 기반 리눅스 시스템 로그 요약 도구\n"
  echo "사용법: $0 /path/to/logfile"
  echo
  echo "예시:"
  echo "  $0 /var/log/syslog"
  echo
  echo "기능:"
  echo "  - 마지막 50줄 로그를 읽어 GPT-4로 요약"
  echo "  - 한국어 요약 결과 출력"
  echo
  echo "환경변수:"
  echo "  OPENAI_API_KEY : OpenAI API 키를 환경변수로 설정해야 합니다"
  echo
  exit 0
fi

LOGFILE=$1
TMP_RESPONSE="/tmp/logpeek_response.json"
TMP_JSON="/tmp/logpeek_request.json"

if [ -z "$LOGFILE" ]; then
  echo "사용법: $0 /path/to/logfile"
  echo "도움말: $0 -h"
  exit 1
fi

if [ -z "$OPENAI_API_KEY" ]; then
  echo "❌ OPENAI_API_KEY가 설정되지 않았습니다."
  echo "export OPENAI_API_KEY=your-key 형태로 설정해주세요."
  exit 1
fi

if [ ! -f "$LOGFILE" ]; then
  echo "❌ 로그 파일이 존재하지 않습니다: $LOGFILE"
  exit 1
fi

LOG=$(tail -n 50 "$LOGFILE")
SAFE_LOG=$(jq -Rs <<< "$LOG")

cat > "$TMP_JSON" <<EOF
{
  "model": "gpt-4",
  "messages": [
    {
      "role": "system",
      "content": "당신은 유능한 리눅스 시스템 로그 분석가입니다. 사용자의 요청에 따라 실제 로그에 나타난 현상만 짧고 명확하게 요약해줍니다. 필요하지 않다면 일반적인 조언은 생략합니다."
    },
    {
      "role": "user",
      "content": $SAFE_LOG
    }
  ]
}
EOF

echo "⏳ GPT에 요청 중... (마지막 50줄 분량을 분석합니다.)"
sleep 0.5

curl https://api.openai.com/v1/chat/completions \
  -sS \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  --data-binary @"$TMP_JSON" > "$TMP_RESPONSE"

if jq -e .choices[0].message.content "$TMP_RESPONSE" > /dev/null 2>&1; then
  echo "✅ 분석 결과:"
  jq -r '.choices[0].message.content' "$TMP_RESPONSE"
else
  echo "❌ GPT 응답 파싱 실패. 전체 응답:"
  cat "$TMP_RESPONSE"
fi
