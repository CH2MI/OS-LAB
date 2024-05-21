#!/bin/bash

# xv6 디렉토리로 이동
cd xv6

# kernelmemfs 빌드
make kernelmemfs

# 상위 디렉토리로 이동
cd ..

# kernelmemfs를 image/kernel로 복사
cp xv6/kernelmemfs image/kernel

echo "kernelmemfs를 빌드하고 image/kernel로 복사했습니다."
