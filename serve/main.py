import time
import ray
from ray import serve
from serve import model

def do_launch(grace_period: int = 240):
    serve.run(model.bind())  # type: ignore

if __name__ == "__main__":
    import argparse
    print("Waiting....")
    time.sleep(10)
    parser = argparse.ArgumentParser(description='Launch model serving')
    parser.add_argument('--ray-head', type=str, required=False,
                        help='Head node to submit to')
    args = parser.parse_args()
    if args.ray_head is not None:
        ray.init(args.ray_head, namespace="farts")
    else:
        ray.init("auto", namespace="farts")
    result = do_launch(actor_count=args.actor_count)
    print(f"Got back {result} from launch")