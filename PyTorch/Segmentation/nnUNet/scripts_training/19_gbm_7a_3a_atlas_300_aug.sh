#!/bin/bash
task=20
task_folder='20_3d'
name='3a_atlas_aug_300'

# python3 ../preprocess.py --data /data/private_data/ --task $task --ohe --exec_mode training --results /data/private_data/

mkdir /results/gbm_results/$name
mkdir /results/gbm_results/$name/fold-0
echo Training $name fold-0!

export CUDA_VISIBLE_DEVICES=1 && python3 ../main.py --brats --data /data/private_data/${task}_3d --results /results/gbm_results/$name/fold-0 --deep_supervision --depth 6 --filters 64 96 128 192 256 384 512 --min_fmap 2 --scheduler --learning_rate 0.0003 --epochs 300 --nfolds 3 --fold 0 --amp --gpus 1 --task $task --patience 20 --save_ckpt 


mkdir /results/gbm_results/$name/fold-1
echo Training $name fold-1!

export CUDA_VISIBLE_DEVICES=1 && python3 ../main.py --brats --data /data/private_data/${task}_3d --results /results/gbm_results/$name/fold-1 --deep_supervision --depth 6 --filters 64 96 128 192 256 384 512 --min_fmap 2 --scheduler --learning_rate 0.0003 --epochs 300 --nfolds 3 --fold 1 --amp --gpus 1 --task $task --patience 20 --save_ckpt

mkdir /results/gbm_results/$name/fold-2
echo Training $name fold-2!

export CUDA_VISIBLE_DEVICES=1 && python3 ../main.py --brats --data /data/private_data/${task}_3d --results /results/gbm_results/$name/fold-2 --deep_supervision --depth 6 --filters 64 96 128 192 256 384 512 --min_fmap 2 --scheduler --learning_rate 0.0003 --epochs 300 --nfolds 3 --fold 2 --amp --gpus 1 --task $task --patience 20 --save_ckpt

echo End Training!

echo Save predicts $name fold-0!
mkdir /results/gbm_infer/$name

export CUDA_VISIBLE_DEVICES=1 && python ../main.py --exec_mode predict --task ${task}_3d --data /data/private_data/${task}_3d --brats --dim 3 --fold 0 --nfolds 3 --ckpt_path /results/gbm_results/$name/fold-0/checkpoints/best*.ckpt --results /results/gbm_infer/$name --amp --tta --save_preds

python metrics.py --path_to_pred /results/gbm_infer/$name/*fold=0_tta --path_to_target  /data/private_data/gbm_3a_atlas_train/labels --out /results/gbm_infer/$name/metrics_gbm_${name}_fold-0.csv

 echo Save predicts $name fold-1!

# export CUDA_VISIBLE_DEVICES=1 && python ../main.py --exec_mode predict --task ${task}_3d --data /data/private_data/${task}_3d --brats --dim 3 --fold 1 --nfolds 3 --ckpt_path /results/gbm_results/$name/fold-1/checkpoints/best*.ckpt --results /results/gbm_infer/$name --amp --tta --save_preds

python metrics.py --path_to_pred /results/gbm_infer/$name/*fold=1_tta --path_to_target  /data/private_data/gbm_3a_atlas_train/labels --out /results/gbm_infer/$name/metrics_gbm_${name}_fold-1.csv

echo Save predicts $name fold-2!

# export CUDA_VISIBLE_DEVICES=1 && python ../main.py --exec_mode predict --task ${task}_3d --data /data/private_data/${task}_3d --brats --dim 3 --fold 2 --nfolds 3 --ckpt_path /results/gbm_results/$name/fold-2/checkpoints/best*.ckpt --results /results/gbm_infer/$name --amp --tta --save_preds

python metrics.py --path_to_pred /results/gbm_infer/$name/*fold=2_tta --path_to_target  /data/private_data/gbm_3a_atlas_train/labels --out /results/gbm_infer/$name/metrics_gbm_${name}_fold-2.csv