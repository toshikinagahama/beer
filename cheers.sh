# !/bin/bash
readonly H_TER=$(tput lines)                      #ターミナルの縦幅
readonly W_TER=$(tput cols)                       #ターミナルの横幅
w1=$((W_TER * 30 / 100))                          #計算用w
readonly MIN_W_MUG=$((w1 % 2 == 0 ? w1 : w1 + 1)) #ビールジョッキの最大の横幅（形は後で変える）必ず偶数
readonly H_MUG=$((H_TER * 40 / 100))              #ビールジョッキの縦幅
readonly Y_BOTTOM=$((H_TER - 5))                  #ジョッキの底の位置
readonly YELLOW="\033[33m"                        #黄色
readonly WHITE="\033[37m"                         #白色
readonly RESET="\033[0m"                          #リセット
readonly POUR_SPEED=500                           #注ぐ速度
readonly MOVE_SPEED=$((MIN_W_MUG / 3 * 2))        #ビールジョッキ登場スピード
readonly UP="\033[1A"                             #カーソル上
readonly DOWN="\033[1B"                           #カーソル下
readonly RIGHT="\033[1C"                          #カーソル右
readonly LEFT="\033[1D"                           #カーソル左

#ビールジョッキの横幅
function get_beer_w() {
  local h=$1
  local w=$((h * 60 / 100 + MIN_W_MUG))
  #local w=$((-20 / (h + 1) * 60 / 100 + MIN_W_MUG))
  if ((w % 2 == 1)); then
    #奇数だとズレちゃう
    w=$((w + 1))
  fi
  echo "$w"
}

#ジョッキの描画
function draw_mug() {
  local x=$1
  local y0=$2
  buffer="${WHITE}\033[H"
  for ((i = 0; i < H_MUG; i++)); do
    full_line="${MUG_LINES[i]}"
    y=$((y0 - i))
    if ((x < 1)); then
      offset=$((1 - x))
      draw_line="${full_line:$offset}"
      draw_x=1
    else
      draw_line="$full_line"
      draw_x=$x
    fi
    # \033[Kは行末までクリア、\033[y;xHは座標指定
    buffer+="\033[${y};1H\033[K\033[${y};${draw_x}H${draw_line}"
  done
  echo -ne "$buffer${RESET}"
}

#注ぎ口の描画
function draw_spout() {
  offset_x=$1
  offset_y=$2
  tput cup $offset_y $offset_x

  FIG_SPOUT="/   /${UP}${LEFT}${LEFT}${LEFT}${LEFT}"
  FIG_SPOUT+="/   /${UP}${LEFT}${LEFT}${LEFT}${LEFT}"
  FIG_SPOUT+="/   /${UP}${LEFT}${LEFT}${LEFT}${LEFT}"
  FIG_SPOUT+="|   |"
  echo -ne "${FIG_SPOUT}"
}

WS_MUG=()
for ((i = 0; i < H_MUG; i++)); do
  WS_MUG[i]=$(get_beer_w "$i")
done

tput clear #画面をクリア
tput civis #カーソル消す
printf "\\$(printf '%03o' $((33 + RANDOM % 94)))\n"
MUG_LINES=()
W_BASE=$((H_MUG * 60 / 100 + MIN_W_MUG)) # 1番広い幅
if ((W_BASE % 2 == 1)); then
  W_BASE=$((W_BASE + 1))
fi

for ((i = 0; i < H_MUG; i++)); do
  w_current=${WS_MUG[i]}
  indent=$(((W_BASE - w_current) / 2))
  line=$(printf "%${indent}s" "") #左インデント
  if ((i == 0)); then
    line+=$(printf "%${w_current}s" "" | tr ' ' '#')
  else
    inner_w=$((w_current - 2))
    line+="#"$(printf "%${inner_w}s" "")"#"
  fi
  MUG_LINES[$i]="$line"
done

##########################################
##########################################
# ビールジョッキを左から登場させる       #
##########################################
##########################################
x0=0                                                                  # 基準
y0=$Y_BOTTOM                                                          # 基準
offset_mug_x=$(((WS_MUG[H_MUG - 1] - WS_MUG[0]) / 2 + WS_MUG[0] / 2)) #ジョッキの左端
offset_y=$((Y_BOTTOM - H_MUG - 5))                                    #注ぎ口の下端
offset_x=$((offset_mug_x + MOVE_SPEED))                               #注ぎ口の左端
for ((x = $((-W_BASE - 10)); x < MOVE_SPEED; x++)); do
  draw_mug $x $y0 # ビールの描画
  draw_spout $((offset_x)) $offset_y
  # 注ぎ口の描画
  sleep 0.008
done

# 注ぎ描画 100フレームで5秒間
bottom_beer=$((offset_y))
total_time=5
bottom_frame=100
num_frame=100
draw_spout $offset_x $offset_y
for ((f = 0; f < $((total_time * num_frame)); f++)); do
  bottom_beer=$((offset_y - 20 * f / 100)) #注がれるビールの液面
  if ((bottom_beer <= $((offset_y - H_MUG - 3)))); then
    # 液体の描画
    current_height=$((H_MUG * 180 * (f - bottom_frame) / num_frame / total_time / 100))
    if ((current_height > H_MUG)); then
      current_height=H_MUG
      #注ぎを消す
      # 注ぎ口の描画
      tput cup $((offset_y + 1)) $offset_mug_x
      line="${YELLOW}"
      for ((o = 0; o < MOVE_SPEED; o++)); do
        line+="${RIGHT}"
      done
      for ((h = 0; h < 4; h++)); do
        for ((w = 0; w < 4; w++)); do
          line+=" "
        done
        line+="${DOWN}"
        for ((w = 0; w < 4; w++)); do
          line+="${LEFT}"
        done
      done
      line+="${RESET}"
      echo -ne "$line"
    fi
    beer=""
    tput cup $((Y_BOTTOM - 2)) $MOVE_SPEED
    for ((h = 1; h < current_height; h++)); do
      if ((h <= H_MUG - 3)); then
        #上から3つは泡にしたい
        offset_beer_x=$(((WS_MUG[H_MUG - 1] - WS_MUG[h]) / 2))
        for ((w = 0; w < offset_beer_x; w++)); do
          beer+="${RIGHT}"
        done
        f_h=$((h * num_frame * total_time * 180 / 100 / H_MUG + bottom_frame)) #その高さがくる時間
        p_y=$((5000 * (f - f_h) / num_frame / total_time))                     # 確率小数扱えないので、100倍
        for ((w = 0; w < WS_MUG[h] - 2; w++)); do
          if ((RANDOM % 1000 <= p_y)); then
            beer+="${YELLOW}█${RESET}"
          else
            beer+="${WHITE}█${RESET}"
          fi
        done
        beer+="${UP}"
        for ((w = 0; w < WS_MUG[h] - 2; w++)); do
          beer+="${LEFT}"
        done
        for ((w = 0; w < offset_beer_x; w++)); do
          beer+="${LEFT}"
        done
      else
        offset_beer_x=$(((WS_MUG[H_MUG - 1] - WS_MUG[h]) / 2))
        for ((w = 0; w < offset_beer_x; w++)); do
          beer+="${RIGHT}"
        done
        f_h=$((h * num_frame * total_time * 180 / 100 / H_MUG + bottom_frame)) #その高さがくる時間
        p_y=$((1000 * (f - f_h) / num_frame / total_time))                     # 確率小数扱えないので、100倍
        for ((w = 0; w < WS_MUG[h] - 2; w++)); do
          if ((RANDOM % 1000 <= p_y)); then
            beer+="${YELLOW}█${RESET}"
          else
            beer+="${WHITE}█${RESET}"
          fi
        done
        beer+="${UP}"
        for ((w = 0; w < WS_MUG[h] - 2; w++)); do
          beer+="${LEFT}"
        done
        for ((w = 0; w < offset_beer_x; w++)); do
          beer+="${LEFT}"
        done
      fi
    done
    echo -ne "$beer"
  else
    # 注ぎ口の描画
    tput cup $((offset_y + 1)) $offset_mug_x
    line="${YELLOW}"
    for ((o = 0; o < MOVE_SPEED; o++)); do
      line+="${RIGHT}"
    done
    for ((h = offset_y; h >= bottom_beer; h--)); do
      for ((w = 0; w < 4; w++)); do
        line+="█"
      done
      line+="${DOWN}"
      for ((w = 0; w < 4; w++)); do
        line+="${LEFT}"
      done
    done
    line+="${RESET}"
    echo -ne "$line"
  fi

  sleep 0.001
done

tput cup $HEIGHT_TERMINAL 0
tput cnorm #カーソル表示
