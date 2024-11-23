require 'erb'

# サンプルデータ (attribute)
attribute = { 'router-id' => '192.168.255.101',
              'confederation-id' => 65_518,
              'confederation-member' => [65_500],
              'route-reflector' => true,
              'peer-group' => [],
              'policy' =>
               [{ 'name' => 'ipv4-core',
                  'default' => { 'actions' => [{ 'target' => 'reject' }] },
                  'statements' =>
                   [{ 'name' => 'bgp', 'actions' => [{ 'target' => 'accept' }], 'conditions' => [{ 'protocol' => 'bgp' }], 'if' => 'if' },
                    { 'name' => 'aggregate-static',
                      'actions' => [{ 'community' => { 'action' => 'set', 'name' => 'aggregated' } },
                                    { 'next-hop' => '172.31.255.1' }, { 'target' => 'accept' }],
                      'conditions' =>
                       [{ 'protocol' => 'static' },
                        { 'rib' => 'inet.0' },
                        { 'route-filter' => { 'length' => {}, 'match-type' => 'exact', 'prefix' => '10.100.0.0/16' } },
                        { 'route-filter' => { 'length' => {}, 'match-type' => 'exact', 'prefix' => '10.110.0.0/20' } },
                        { 'route-filter' => { 'length' => {}, 'match-type' => 'exact', 'prefix' => '10.120.0.0/17' } },
                        { 'route-filter' => { 'length' => {}, 'match-type' => 'exact', 'prefix' => '10.130.0.0/21' } },
                        { 'route-filter' => { 'length' => {}, 'match-type' => 'exact',
                                              'prefix' => '172.31.255.1/32' } }],
                      'if' => 'if' }] },
                { 'name' => 'ipv4-full',
                  'default' => { 'actions' => [{ 'target' => 'reject' }] },
                  'statements' =>
                   [{ 'name' => 'bgp', 'actions' => [{ 'target' => 'accept' }], 'conditions' => [{ 'protocol' => 'bgp' }], 'if' => 'if' },
                    { 'name' => 'aggregate-static',
                      'actions' => [{ 'community' => { 'action' => 'set', 'name' => 'aggregated' } },
                                    { 'next-hop' => '172.31.255.1' }, { 'target' => 'accept' }],
                      'conditions' =>
                       [{ 'protocol' => 'static' },
                        { 'rib' => 'inet.0' },
                        { 'route-filter' => { 'length' => {}, 'match-type' => 'exact', 'prefix' => '10.100.0.0/16' } },
                        { 'route-filter' => { 'length' => {}, 'match-type' => 'exact', 'prefix' => '10.110.0.0/20' } },
                        { 'route-filter' => { 'length' => {}, 'match-type' => 'exact', 'prefix' => '10.120.0.0/17' } },
                        { 'route-filter' => { 'length' => {}, 'match-type' => 'exact', 'prefix' => '10.130.0.0/21' } },
                        { 'route-filter' => { 'length' => {}, 'match-type' => 'exact',
                                              'prefix' => '172.31.255.1/32' } }],
                      'if' => 'if' },
                    { 'name' => 'default-static',
                      'actions' => [{ 'next-hop' => '172.31.255.1' }, { 'target' => 'accept' }],
                      'conditions' =>
                       [{ 'protocol' => 'static' }, { 'rib' => 'inet.0' },
                        { 'route-filter' => { 'length' => {}, 'match-type' => 'exact', 'prefix' => '0.0.0.0/0' } }],
                      'if' => 'if' }] }],
              'prefix-set' => [],
              'as-path-set' => [],
              'community-set' => [{ 'name' => 'aggregated', 'communities' => [{ 'community' => '65518:1' }] }],
              'redistribute' => [],
              'flag' => [],
              '_diff_state_' => { forward: :kept, backward: nil, pair: '' } }

# 再帰的にデータをMarkdownに整形するメソッド
def render_recursive(key, value, depth = 0)
  indent = '  ' * depth # インデントで階層を表現
  result = ''

  # '_diff_state_' キーをスキップ
  return result if key == '_diff_state_'

  case value
  when Hash
    result << "#{indent}- **#{key}**:\n" if key
    value.each do |k, v|
      result << render_recursive(k, v, depth + 1)
    end
  when Array
    result << "#{indent}- **#{key}**:\n" if key
    if value.empty?
      result << "#{indent}  - (empty)\n"
    else
      value.each do |v|
        result << render_recursive(nil, v, depth + 1)
      end
    end
  else
    result << if key
                "#{indent}- **#{key}**: #{value}\n"
              else
                "#{indent}- #{value}\n"
              end
  end

  result
end

# ERBテンプレート
template = <<~ERB
  # 属性情報

  以下は属性データをMarkdown形式に整形した結果です。

  <%= render_recursive(nil, attribute) %>
ERB

# ERBの処理
renderer = ERB.new(template)
output = renderer.result(binding)

# 出力
puts output
