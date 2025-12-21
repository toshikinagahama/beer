# !/bin/bash

HEIGHT_TERMINAL=$(tput lines)          #ターミナルの縦幅
WIDTH_TERMINAL=$(tput cols)            #ターミナルの横幅
WIDTH=$((WIDTH_TERMINAL * 40 / 100))   #ビールジョッキの横幅
HEIGHT=$((HEIGHT_TERMINAL * 50 / 100)) #ビールジョッキの縦幅
YELLOW="\033[33m"
WHITE="\033[37m"
RESET="\033[0m"
POUR_SPEED=500 #注ぐ速度
MOVE_SPEED=100 #ビールジョッキ登場スピード
UP="\033[1A"
DOWN="\033[1B"
RIGHT="\033[1C"
LEFT="\033[1D"
tput clear #画面をクリア
tput civis #カーソル消す

tput cup $((HEIGHT_TERMINAL - 5)) 0
TEST="ABC\nDEF"
#echo -e "${TEST}"

# ビールジョッキを左から登場させる
# for ((speed = 0; speed < MOVE_SPEED; speed++)); do
#   OFFSET_X="\033[$((speed / 5))G"
#   FIG_BUFFER="${OFFSET_X}" #フレーム全体の図
#   for ((i = 0; i < HEIGHT - 2; i++)); do
#     ROW_BUFFER=""
#     if ((i == 0)); then
#       for ((j = 0; j < WIDTH; j++)); do
#         ROW_BUFFER+="${WHITE}+${RESET}"
#       done
#     else
#       ROW_BUFFER+="${WHITE}|${RESET}"
#       for ((j = 0; j < WIDTH - 2; j++)); do
#         ROW_BUFFER+=" "
#       done
#       ROW_BUFFER+="${WHITE}|${RESET}"
#     fi
#     FIG_BUFFER+=${ROW_BUFFER}
#     FIG_BUFFER+="\033[1A\033[$((WIDTH))D"
#   done
#   sleep 0.005
#   tput clear
#   tput cup $((HEIGHT_TERMINAL - 5)) 0
#   FIG_BUFFER+="\033[15B\033[15CABC"
#   echo -ne "${FIG_BUFFER}"
#   #tput cup ${HEIGHT_TERMINAL} ${OFFSET_X}
# done

# ビールジョッキを左から登場させる（カーソル位置で書く）
# これちらついちゃう
for ((speed = 0; speed < MOVE_SPEED; speed++)); do
  CUP_L="" #左端
  CUP_R="" #右端
  CUP_B="" #底
  #左
  for ((i = 0; i < HEIGHT - 2; i++)); do
    CUP_L+="|${UP}${LEFT}"
  done
  for ((i = 0; i < WIDTH - 2; i++)); do
    CUP_R+="${RIGHT}"
  done
  #右
  for ((i = 0; i < HEIGHT - 2; i++)); do
    CUP_R+="|${UP}${LEFT}"
  done
  #底
  CUP_B+="+"
  for ((i = 0; i < WIDTH - 3; i++)); do
    CUP_B+="-"
  done
  CUP_B+="+"

  tput clear
  tput cup $((HEIGHT_TERMINAL - 5)) $((speed / 5))
  echo -ne "${CUP_L}"
  tput cup $((HEIGHT_TERMINAL - 5)) $((speed / 5))
  echo -ne "${CUP_R}"
  tput cup $((HEIGHT_TERMINAL - 5)) $((speed / 5))
  echo -ne "${CUP_B}"
  sleep 0.001
  #tput cup ${HEIGHT_TERMINAL} ${OFFSET_X}
done

# for ((frame = 0; frame < HEIGHT - 2; frame++)); do
#   for ((speed = 0; speed < POUR_SPEED / frame; speed++)); do
#     FIG_BUFFER="" #フレーム全体の図
#     for ((i = 0; i < HEIGHT - 2; i++)); do
#       ROW_BUFFER="|" #1行分
#       if ((i >= HEIGHT - frame)); then
#         for ((j = 0; j < WIDTH; j++)); do
#           if ((RANDOM % 1000 > i)); then
#             ROW_BUFFER+="${YELLOW}█${RESET}"
#           else
#             ROW_BUFFER+="${WHITE}█${RESET}"
#           fi
#         done
#         FIG_BUFFER+="${ROW_BUFFER}|\n"
#       else
#         for ((j = 0; j < WIDTH; j++)); do
#           ROW_BUFFER+=" "
#         done
#         FIG_BUFFER+="${ROW_BUFFER}|\n"
#         #FIG_BUFFER+="\n"
#       fi
#     done
#     tput clear
#     echo -e "${FIG_BUFFER}"
#     sleep 0.002
#   done
# done

tput cup $HEIGHT_TERMINAL 0
tput cnorm #カーソル表示
