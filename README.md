# Elixir Templates

Examples of some patterns in Elixir/OTP which I found useful/interesting.

## Docker Cluster

This template uses `libcluster` and `horde` along with `Phoenix.PubSub` to enable global services to run at set limits independent of horizontal scale. A supervisor will ensure that only the specified number of jobs are present in any given cluster at any given time. The example shown is a `Ticker` which periodically publishes a tick message with timestamp to a pubsub topic. Only one `Ticker` child will be active regardless of how many containers are active. 

### Running

``` sh
cd docker_cluster
docker-compose build
docker-compose up -d
docker-compose logs -f
```

At this point you should see `app-1`, `app-2`, and `app-3` all generating logs. One of the containers should be generating ticks and all three should be generating logs when tick data is received by their listener. Now, scale up the cluster in another terminal and watch the log output.

``` sh
docker-compose up -d --scale app=5
```

You should now see `app-4` and `app-5` join the log output and beginning to receive tick data. Now scale the app back down to just one container.

``` sh
docker-compose up -d --scale app=1
```

You should see four containers gracefully terminate. The container you are left with is likely not the same one that was originally generating ticks, but it will be after the original `Ticker` is killed. 

### Future Improvements (TODO)

- [ ] Persist job data across promotions
- [ ] Write and make conditional a more complex worker (DB interaction)
- [ ] Distribute load on scale-up
