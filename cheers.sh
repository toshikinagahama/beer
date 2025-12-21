# !/bin/bash

readonly H_TER=$(tput lines) #ターミナルの縦幅
readonly W_TER=$(tput cols)  #ターミナルの横幅
calc_w=$((W_TER * 30 / 100))
readonly MIN_W_MUG=$((calc_w % 2 == 0 ? calc_w : calc_w + 1)) #ビールジョッキの最大の横幅（形は後で変える）必ず偶数
readonly H_MUG=$((H_TER * 50 / 100))                          #ビールジョッキの縦幅
readonly YELLOW="\033[33m"
readonly WHITE="\033[37m"
readonly RESET="\033[0m"
readonly POUR_SPEED=500 #注ぐ速度
readonly MOVE_SPEED=40  #ビールジョッキ登場スピード
readonly UP="\033[1A"
readonly DOWN="\033[1B"
readonly RIGHT="\033[1C"
readonly LEFT="\033[1D"

#ビールジョッキの横幅
function get_beer_w() {
  local h=$1
  local w=$((h * 40 / 100 + MIN_W_MUG))
  echo "$w"
}

WS_MUG=()
for ((i = 0; i < H_MUG; i++)); do
  WS_MUG[i]=$(get_beer_w "$i")
done
#echo "${WS_MUG[@]}"

tput clear #画面をクリア
tput civis #カーソル消す

function draw_mug() {
  local t=$1
  mug=""
  for ((i = 0; i < H_MUG; i++)); do
    local w_base=${WS_MUG[H_MUG - 1]}
    local w_current=${WS_MUG[i]}
    local indent=$(((w_base - w_current) / 2))
    for ((j = 0; j < indent; j++)); do
      mug+=" "
    done
    mug+="#"
    if ((i > 0)); then
      for ((j = 0; j < WS_MUG[i] - 2; j++)); do
        mug+=" "
      done
    else
      for ((j = 0; j < WS_MUG[i] - 2; j++)); do
        mug+="#"
      done
    fi
    mug+="#"
    for ((k = 0; k < $((indent + w_current)); k++)); do
      mug+="${LEFT}"
    done
    mug+="${UP}"
  done
  echo -ne "${mug}"
}

function draw() {
  draw_mug
}

draw

#ビールジョッキを左から登場させる
for ((speed = 0; speed < MOVE_SPEED; speed++)); do
  OFFSET_X="\033[$((speed / 3))G"
  tput clear
  tput cup $((H_TER - 5)) $((speed / 4))
  draw_mug

  #注ぎ口の描画
  tput cup $((H_TER - H_MUG - 10)) $((MIN_W_MUG + 10 + MOVE_SPEED / 3 - 10))

  FIG_SPOUT=""
  FIG_SPOUT+="|   |${DOWN}${LEFT}${LEFT}${LEFT}${LEFT}${LEFT}${LEFT}"
  FIG_SPOUT+="/   /${DOWN}${LEFT}${LEFT}${LEFT}${LEFT}${LEFT}${LEFT}${LEFT}"
  FIG_SPOUT+="/   /"
  echo -ne "${FIG_SPOUT}"
  sleep 0.01

done
#
# tput cup $((HEIGHT_TERMINAL - 5)) 0
# for ((frame = -HEIGHT; frame < HEIGHT - 2; frame++)); do
#   for ((speed = 0; speed < 10; speed++)); do
#     #最初の10フレームは注ぎ描写
#     if ((frame >= 0)); then
#       FIG_BUFFER="${OFFSET_X}" #フレーム全体の図
#       for ((i = 0; i < HEIGHT - 2; i++)); do
#         ROW_BUFFER=""
#         if ((i == 0)); then
#           ROW_BUFFER+="${WHITE}+${RESET}"
#           for ((j = 0; j < WIDTH - 2; j++)); do
#             ROW_BUFFER+="${WHITE}-${RESET}"
#           done
#           ROW_BUFFER+="${WHITE}+${RESET}"
#         else
#           ROW_BUFFER="${WHITE}|${RESET}"
#           if ((i <= frame)); then
#             for ((j = 0; j < WIDTH - 2; j++)); do
#               if ((frame - i <= HEIGHT / 2)); then
#                 #下の方ほど泡（白の割合が多い）
#                 if ((RANDOM % HEIGHT >= i)); then
#                   ROW_BUFFER+="${YELLOW}█${RESET}"
#                 else
#                   ROW_BUFFER+="${WHITE}█${RESET}"
#                 fi
#               else
#                 ROW_BUFFER+="${YELLOW}█${RESET}"
#               fi
#             done
#           else
#             for ((j = 0; j < WIDTH - 2; j++)); do
#               ROW_BUFFER+=" "
#             done
#           fi
#           ROW_BUFFER+="${WHITE}|${RESET}"
#         fi
#         FIG_BUFFER+="${ROW_BUFFER}"
#         FIG_BUFFER+="${UP}"
#         for ((j = 0; j < WIDTH; j++)); do
#           FIG_BUFFER+="${LEFT}"
#         done
#       done
#       #tput clear
#       tput cup $((HEIGHT_TERMINAL - 5)) 0
#       echo -ne "${FIG_BUFFER}"
#       #注ぎ口の描画
#       tput cup $((HEIGHT_TERMINAL - HEIGHT - 10)) $((WIDTH + MOVE_SPEED / 3 - 10))
#       FIG_SPOUT=""
#       FIG_SPOUT+="|   |${DOWN}${LEFT}${LEFT}${LEFT}${LEFT}${LEFT}${LEFT}"
#       FIG_SPOUT+="/   /${DOWN}${LEFT}${LEFT}${LEFT}${LEFT}${LEFT}${LEFT}${LEFT}"
#       FIG_SPOUT+="/   /${DOWN}${LEFT}${LEFT}${LEFT}${LEFT}${LEFT}${LEFT}"
#       echo -ne "${FIG_SPOUT}"
#
#       #ビール水滴の描画
#       tput cup $((HEIGHT_TERMINAL - HEIGHT - 8)) $((WIDTH + MOVE_SPEED / 3 - 12))
#       FIG_POUR=""
#       for ((y = 0; y < HEIGHT; y++)); do
#         FIG_POUR+="███${DOWN}${LEFT}${LEFT}${LEFT}${LEFT}"
#       done
#       echo -ne "${YELLOW}${FIG_POUR}${RESET}"
#     else
#       #ビール水滴の描画
#       tput cup $((HEIGHT_TERMINAL - HEIGHT - 8)) $((WIDTH + MOVE_SPEED / 3 - 12))
#       FIG_POUR=""
#       for ((y = 0; y < frame + HEIGHT; y++)); do
#         FIG_POUR+="███${DOWN}${LEFT}${LEFT}${LEFT}${LEFT}"
#       done
#       echo -ne "${YELLOW}${FIG_POUR}${RESET}"
#     fi
#     sleep 0.001
#   done
# done
#
# # 注ぎ終わったあと
# for ((frame = 0; frame < HEIGHT - 2; frame++)); do
#   for ((speed = 0; speed < 10; speed++)); do
#     FIG_BUFFER="${OFFSET_X}" #フレーム全体の図
#     for ((i = 0; i < HEIGHT - 2; i++)); do
#       ROW_BUFFER=""
#       if ((i == 0)); then
#         ROW_BUFFER+="${WHITE}+${RESET}"
#         for ((j = 0; j < WIDTH - 2; j++)); do
#           ROW_BUFFER+="${WHITE}-${RESET}"
#         done
#         ROW_BUFFER+="${WHITE}+${RESET}"
#       else
#         ROW_BUFFER="${WHITE}|${RESET}"
#         for ((j = 0; j < WIDTH - 2; j++)); do
#           if ((frame - i <= HEIGHT / 2)); then
#             #徐々に泡が抜けていく
#             if ((RANDOM % HEIGHT >= i)); then
#               ROW_BUFFER+="${YELLOW}█${RESET}"
#             else
#               ROW_BUFFER+="${WHITE}█${RESET}"
#             fi
#           else
#             ROW_BUFFER+="${YELLOW}█${RESET}"
#           fi
#         done
#         ROW_BUFFER+="${WHITE}|${RESET}"
#       fi
#       FIG_BUFFER+="${ROW_BUFFER}"
#       FIG_BUFFER+="${UP}"
#       for ((j = 0; j < WIDTH; j++)); do
#         FIG_BUFFER+="${LEFT}"
#       done
#     done
#     #tput clear
#     tput cup $((HEIGHT_TERMINAL - 5)) 0
#     echo -ne "${FIG_BUFFER}"
#     sleep 0.002
#   done
# done

tput cup $HEIGHT_TERMINAL 0
tput cnorm #カーソル表示
