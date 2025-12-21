# !/bin/bash

HEIGHT_TERMINAL=$(tput lines)          #ターミナルの縦幅
WIDTH_TERMINAL=$(tput cols)            #ターミナルの横幅
WIDTH=$((WIDTH_TERMINAL * 40 / 100))   #ビールジョッキの横幅
HEIGHT=$((HEIGHT_TERMINAL * 50 / 100)) #ビールジョッキの縦幅
YELLOW="\033[33m"
WHITE="\033[37m"
RESET="\033[0m"
POUR_SPEED=500 #注ぐ速度
MOVE_SPEED=40  #ビールジョッキ登場スピード
UP="\033[1A"
DOWN="\033[1B"
RIGHT="\033[1C"
LEFT="\033[1D"
tput clear #画面をクリア
tput civis #カーソル消す

tput cup $((HEIGHT_TERMINAL - 5)) 0
TEST="ABC\nDEF"
#echo -e "${TEST}"

#ビールジョッキを左から登場させる
for ((speed = 0; speed < MOVE_SPEED; speed++)); do
  OFFSET_X="\033[$((speed / 3))G"
  FIG_BUFFER="${OFFSET_X}" #フレーム全体の図
  for ((i = 0; i < HEIGHT - 2; i++)); do
    ROW_BUFFER=""
    if ((i == 0)); then
      ROW_BUFFER+="${WHITE}+${RESET}"
      for ((j = 0; j < WIDTH - 2; j++)); do
        ROW_BUFFER+="${WHITE}-${RESET}"
      done
      ROW_BUFFER+="${WHITE}+${RESET}"
    else
      ROW_BUFFER+="${WHITE}|${RESET}"
      for ((j = 0; j < WIDTH - 2; j++)); do
        ROW_BUFFER+=" "
      done
      ROW_BUFFER+="${WHITE}|${RESET}"
    fi
    FIG_BUFFER+=${ROW_BUFFER}
    FIG_BUFFER+="${UP}"
    for ((j = 0; j < WIDTH; j++)); do
      FIG_BUFFER+="${LEFT}"
    done
  done
  tput clear
  tput cup $((HEIGHT_TERMINAL - 5)) 0
  echo -ne "${FIG_BUFFER}"
  sleep 0.0001
  #tput cup ${HEIGHT_TERMINAL} ${OFFSET_X}
done

tput cup $((HEIGHT_TERMINAL - 5)) 0

for ((frame = 0; frame < HEIGHT - 2; frame++)); do
  for ((speed = 0; speed < 10; speed++)); do
    FIG_BUFFER="${OFFSET_X}" #フレーム全体の図
    for ((i = 0; i < HEIGHT - 2; i++)); do
      ROW_BUFFER=""
      if ((i == 0)); then
        ROW_BUFFER+="${WHITE}+${RESET}"
        for ((j = 0; j < WIDTH - 2; j++)); do
          ROW_BUFFER+="${WHITE}-${RESET}"
        done
        ROW_BUFFER+="${WHITE}+${RESET}"
      else
        ROW_BUFFER="${WHITE}|${RESET}"
        if ((i <= frame)); then
          for ((j = 0; j < WIDTH - 2; j++)); do
            if ((frame - i <= HEIGHT / 2)); then
              #下の方ほど泡（白の割合が多い）
              if ((RANDOM % HEIGHT >= i)); then
                ROW_BUFFER+="${YELLOW}█${RESET}"
              else
                ROW_BUFFER+="${WHITE}█${RESET}"
              fi
            else
              ROW_BUFFER+="${YELLOW}█${RESET}"
            fi
          done
        else
          for ((j = 0; j < WIDTH - 2; j++)); do
            ROW_BUFFER+=" "
          done
        fi
        ROW_BUFFER+="${WHITE}|${RESET}"
      fi
      FIG_BUFFER+="${ROW_BUFFER}"
      FIG_BUFFER+="${UP}"
      for ((j = 0; j < WIDTH; j++)); do
        FIG_BUFFER+="${LEFT}"
      done
    done
    tput clear
    tput cup $((HEIGHT_TERMINAL - 5)) 0
    echo -ne "${FIG_BUFFER}"
    sleep 0.0002
  done
done

# 注ぎ終わったあと
for ((frame = 0; frame < HEIGHT - 2; frame++)); do
  for ((speed = 0; speed < 10; speed++)); do
    FIG_BUFFER="${OFFSET_X}" #フレーム全体の図
    for ((i = 0; i < HEIGHT - 2; i++)); do
      ROW_BUFFER=""
      if ((i == 0)); then
        ROW_BUFFER+="${WHITE}+${RESET}"
        for ((j = 0; j < WIDTH - 2; j++)); do
          ROW_BUFFER+="${WHITE}-${RESET}"
        done
        ROW_BUFFER+="${WHITE}+${RESET}"
      else
        ROW_BUFFER="${WHITE}|${RESET}"
        for ((j = 0; j < WIDTH - 2; j++)); do
          if ((frame - i <= HEIGHT / 2)); then
            #徐々に泡が抜けていく
            if ((RANDOM % HEIGHT >= i)); then
              ROW_BUFFER+="${YELLOW}█${RESET}"
            else
              ROW_BUFFER+="${WHITE}█${RESET}"
            fi
          else
            ROW_BUFFER+="${YELLOW}█${RESET}"
          fi
        done
        ROW_BUFFER+="${WHITE}|${RESET}"
      fi
      FIG_BUFFER+="${ROW_BUFFER}"
      FIG_BUFFER+="${UP}"
      for ((j = 0; j < WIDTH; j++)); do
        FIG_BUFFER+="${LEFT}"
      done
    done
    tput clear
    tput cup $((HEIGHT_TERMINAL - 5)) 0
    echo -ne "${FIG_BUFFER}"
    sleep 0.002
  done
done

tput cup $HEIGHT_TERMINAL 0
tput cnorm #カーソル表示
