from concurrent.futures import ProcessPoolExecutor, ThreadPoolExecutor, as_completed

from benchmark.config import num_cpus


def run_mt(fn, run_config: dict, extra_args=None):
    num_threads = run_config.get("num_threads_per_process") or 5
    with ThreadPoolExecutor(max_workers=num_threads) as executor:
        future_to_thread = {}
        for x in range(num_threads):
            if isinstance(extra_args, list) and len(extra_args) == num_threads:
                future = executor.submit(fn, run_config, extra_args[x])
            else:
                future = executor.submit(fn, run_config)
            future_to_thread[future] = f"thread_{x}"

        for future in as_completed(future_to_thread):
            run = future_to_thread[future]
            try:
                _ = future.result()
            except Exception as exc:
                print('%r generated an exception: %s' % (run, exc))


def run_mp(fn, run_config: dict, extra_args=None):
    num_processes = num_cpus
    with ProcessPoolExecutor(max_workers=num_processes) as executor:
        future_to_process = {
            executor.submit(
                run_mt, fn, run_config, extra_args
            ): f"process_{x}"
            for x in range(num_processes)
        }
        for future in as_completed(future_to_process):
            process = future_to_process[future]
            try:
                _ = future.result()
            except Exception as exc:
                print('%r generated an exception: %s' % (process, exc))
