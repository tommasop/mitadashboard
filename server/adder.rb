(1..1000).each do |a|
  system `echo "#{rand(10..100)};#{rand(10..100)};#{rand(10..100)};#{rand(10..100)};#{rand(10..100)}" >> /Users/tommasop/work/progetti_servizi/dash_scratch/tom`
  sleep(0.2)
end
