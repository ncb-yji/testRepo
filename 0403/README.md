# **2025-04-23 과제 : 리눅스 실습 - CLI 프로그램 만들어보기**
## **logpeek.sh**
logpeek은 GPT-4 모델을 활용해 리눅스 시스템 로그를 자동으로 요약해서 설명해주는 터미널 기반 CLI 도구입니다.
✅ 최신 로그 50줄 요약	로그 파일에서 마지막 50줄을 읽어 GPT에 전달
🇰🇷 한국어 출력 지원	결과를 한국어로 친절하게 제공

##**<사용법>**
# 1. 먼저 OpenAI API 키를 환경 변수로 등록합니다.
export OPENAI_API_KEY="sk-...여기에_본인의_API_키..."
# 2. 분석하고 싶은 로그 파일을 지정하여 실행합니다.
./logpeek.sh /var/log/syslog
**-h**: 도움말 옵션	CLI에서 도움말 보기 가능

## **<테스트 시나리오>**
아래 명령어를 터미널에 입력하면 테스트용 로그를 생성할 수 있습니다.

#1. 일반적인 SSH 로그인 실패 (보안 테스트)
echo -e "Apr 23 10:01:00 ubuntu sshd[1234]: Failed password for root from 192.168.0.10 port 45123 ssh2" > test1.log
#2. CPU soft lockup (시스템 오류)
echo -e "Apr 23 10:02:10 ubuntu kernel: [12345.678901] CPU0: soft lockup - CPU#0 stuck for 22s! [kworker/0:1:1234]" > test2.log
#3. 웹 서버 실행 실패 (서비스 장애)
echo -e "Apr 23 10:03:21 ubuntu apache2[5678]: AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 127.0.1.1. Set the 'ServerName' directive globally to suppress this message" > test3.log
#4. Nginx 설정 오류 (구문 에러)
echo -e "Apr 23 10:04:01 ubuntu nginx[9123]: nginx: [emerg] unexpected \"}\" in /etc/nginx/sites-enabled/default:45" > test4.log
#5. 디스크 공간 부족 (운영 이슈)
echo -e "Apr 23 10:05:12 ubuntu systemd[1]: Starting Daily apt download activities...\nApr 23 10:05:12 ubuntu systemd[1]: apt-daily.service: Failed to run 'start-pre' task: No space left on 
device" > test5.log
#6. 정상 작동 로그 (비교용)
echo -e "Apr 23 10:06:30 ubuntu systemd[1]: Started nginx - high performance web server.\nApr 23 10:06:30 ubuntu systemd[1]: Reached target Multi-User System." > test6.log
