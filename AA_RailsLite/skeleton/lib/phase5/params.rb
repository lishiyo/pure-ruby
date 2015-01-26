require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      # hash of params keys and values
      # queries = req.query_string.split("?")[1]

      queries = parse_www_encoded_form(req.query_string)
      post_body = parse_www_encoded_form(req.body)
      puts "queries: #{queries}"
      puts "post_body: #{post_body}"
      @params = queries.merge(post_body).merge(route_params)
      puts "params: #{@params}"
    end

    def [](key)
      @params[key.to_s] || @params[key.to_sym]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(query_str)
      return {} if query_str.nil?
      # "user[address][street]=main"=> { user => { address => {street => "main"}}}

      hash_arr = URI::decode_www_form(query_str)
      # user[address][street]=main&user[address][zip]=89436
      puts "hash_arr: #{hash_arr}"
      nested = Hash.new {|h, k| h[k] = [] }
      curr_nested = Hash.new
      hash_arr.each do |(keys, final_val)|
        key_arr = parse_key(keys) # [user, address, street]
        curr_nested = key_arr.reverse.reduce(final_val) do |hash, key|
            { key => hash }
        end
        # {"user"=>{"address"=>{"street"=>"main"}}}
        nested = nested.deep_merge(curr_nested)
      end

      nested
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(keys)
      keys.split(/\]\[|\[|\]/)
    end
  end
end
