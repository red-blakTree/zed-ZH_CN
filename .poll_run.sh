run=44858463228
for i in $(seq 1 170); do
  st=$(curl -sS -m 20 "https://api.github.com/repos/red-blakTree/zed-ZH_CN/actions/runs/$run" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print(d['status'], d.get('conclusion'))
")
  echo "$(date +%H:%M:%S) $st"
  case "$st" in
    completed*) echo "FINAL: $st"; exit 0 ;;
  esac
  sleep 60
done
echo "timeout waiting"
